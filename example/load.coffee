config = require './config'
populate = require '../src/populate'

options =
    dataset: 'set1'
    env: 'local'
    username: null
    password: null

populate(config).load options, (err, res) ->
    if err
        console.log err
        process.exit 1
    else
        console.log res
        process.exit 0
