config = require './config'
fixtures = require '../lib/fixtures'

options =
    dataset: 'set1'
    env: 'local'
    username: null
    password: null


# fixtures(config).load options, (err, res) ->

fixtures(config).interactive (err, res) ->
    if err
        console.log err
        process.exit 1
    else
        console.log res
        process.exit 0
