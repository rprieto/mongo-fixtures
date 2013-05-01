config = require './config'
populate = require '../lib/populate'

options =
    dataset: 'set1'
    env: 'local'
    username: null
    password: null


# populate(config).load options, (err, res) ->

populate(config).interactive (err, res) ->
    if err
        console.log err
        process.exit 1
    else
        console.log res
        process.exit 0
