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
    db.collection collectionName, (error, collection) ->
        verify error
        collection.remove {}, (error) ->
            verify error, "- Removed existing #{collectionName}"
            insertAll collection, documents, () ->
                console.log "- Inserted #{documents.length} #{collectionName}"
                smokeCheck collection, documents
                callback()

insertAll = (collection, documents, callback) ->
    if documents.length == 0
        callback()
    else
        doc = _.head(documents)
        doc.lastUpdatedDate = new Date()
        collection.insert doc, {safe:true}, (error) ->
            verify error, null
            insertAll collection, _.tail(documents), callback

verify = (error, msg) ->
    if error
        throw "!! Failed: #{error}"
    else
        if msg then console.log(msg)

smokeCheck = (collection, documents) ->
    collection.find().toArray (err, inserted) ->
        if inserted.length != documents.length
            throw "!! Check failed. Inserted #{inserted.length} but expected #{documents.length}"
