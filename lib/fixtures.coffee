_ = require 'underscore'
async = require 'async'
interactive = require './interactive'
loader = require './loader'
database = require './database'

module.exports = (config) ->

    load: (target, next) ->
        process config, target, next

    interactive: (next) ->
        interactive.getTarget config, (err, target) ->
            if err then next('Cancelled')
            else process config, target, next


connectionString = (config, target) ->
    config.envs[target.env].database(target.username, target.password)

process = (config, target, callback) ->
    return next("Invalid environment: #{target.env}") unless config.envs[target.env]
    return next("Invalid data set: #{target.dataset}") unless config.datasets[target.dataset]

    database.open connectionString(config, target), (err, db) ->

        if err then return callback(err)

        operations = config.envs[target.env].collections.map (name) ->
            path = config.datasets[target.dataset] + '/' + name
            data = loader.load path, config.envs[target.env].quiet
            (next) -> cleanAndLoad db, name, data, config.envs[target.env], next

        async.series operations, (err, res) ->
            db.close()
            callback err, 'Finished'

cleanAndLoad = (db, collectionName, documents, config, callback) ->
    db.collection collectionName, (err, collection) ->
        if err then return callback(err)

        removeAll   = (next) -> collection.remove {}, next
        insertData  = (next) -> insertAll collection, documents, next
        verify      = (next) -> checkCollectionLength collection, collectionName, documents.length, next
        log         = (next) -> console.log("Inserted #{documents.length} #{collectionName}") unless config.quiet; next();

        async.series [removeAll, insertData, verify, log], callback

insertAll = (collection, documents, callback) ->
    operations = documents.map (doc) ->
        (next) ->
            doc.lastUpdatedDate = new Date()
            collection.insert doc, {safe:true}, next

    async.parallel operations, callback

checkCollectionLength = (collection, name, expectedLength, callback) ->
    collection.find().toArray (err, inserted) ->
        if err
            callback(err)
        else if inserted.length != expectedLength
            callback("Failed: inserted #{inserted.length} into #{name} but expected #{expectedLength}")
        else callback(null)
