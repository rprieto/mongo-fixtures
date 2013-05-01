mongodb = require 'mongodb'
url = require 'url'

serverOptions =
    auto_reconnect: true
    poolSize: 5

parseConnection = (connectionString) ->
    components = url.parse connectionString
    cnx =
        host: components.hostname
        port: parseInt(components.port, 10)
        database: components.pathname.replace(/^\//, '')
    if components.auth
        cnx.username = components.auth.split(':')[0]
        cnx.password = components.auth.split(':')[1]
    cnx

module.exports.open = (connectionString, callback) ->
    cnx = parseConnection connectionString
    server = new mongodb.Server cnx.host, cnx.port, serverOptions
    dbManager = new mongodb.Db cnx.database, server
    dbManager.open (err, client) ->
        if err then throw 'Could not connect to the database'
        if cnx.username
            dbManager.authenticate cnx.username, cnx.password, (err) ->
                if err then throw 'Could not authenticate to the database'
                callback client
        else
            callback client
