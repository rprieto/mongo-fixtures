_ = require 'underscore'
async = require 'async'
readline = require 'readline'
loader = require './loader'
database = require './database'

rl = readline.createInterface
    input: process.stdin
    output: process.stdout

module.exports = (config) ->
    
    load: (target, next) ->
        connectAndLoad config, target, next
        
    interactive: (next) ->
        console.log "Available environments: #{_.keys(config)}"
        promptAll ['dataset', 'env', 'username', 'password'], (err, target) ->
            connectAndLoad config, target, next

promptAll = (keys, next) ->
    prompt = (memo, item, callback) ->
        rl.question "#{item} > ", (value) ->
            memo[item] = value
            callback null, memo
    async.reduce keys, {}, prompt, next

connectAndLoad = (config, target, next) ->
    return next("Invalid environment: #{target.env}") unless config.envs[target.env]
    return next("Invalid data set: #{target.dataset}") unless config.datasets[target.dataset]
    
    database.open connectionString(config, target), (db) ->
        
        operations = config.envs[target.env].collections.map (name) ->
            path = config.datasets[target.dataset] + '/' + name
            data = loader.load path
            (next) -> cleanAndLoad db, name, data, next
        
        async.series operations, (err, res) ->
            db.close()
            next err, 'Finished'

connectionString = (config, target) ->
    config.envs[target.env].database(target.username, target.password)

cleanAndLoad = (db, collectionName, documents, callback) ->
    db.collection collectionName, (err, collection) ->
        if err then return callback(err)
        
        removeAll = (next) -> collection.remove {}, next
        insertData = (next) -> insertAll collection, documents, next
        logInsertion = (next) -> console.log("Inserted #{documents.length} #{collectionName}"); next();
        verify = (next) -> checkCollectionLength collection, documents.length, next
        
        async.series [removeAll, insertData, logInsertion, verify], callback

insertAll = (collection, documents, callback) ->
    if documents.length == 0
        callback()
    else
        doc = _.head(documents)
        doc.lastUpdatedDate = new Date()
        collection.insert doc, {safe:true}, (error) ->
            # verify error, null
            insertAll collection, _.tail(documents), callback

checkCollectionLength = (collection, expectedLength, callback) ->
    collection.find().toArray (err, inserted) ->
        if err
            callback(err)
        else if inserted.length != expectedLength
            callback("Failed: inserted #{inserted.length} but expected #{documents.length}")
        else callback(null)
