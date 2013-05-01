_ = require 'underscore'
prompt = require 'prompt'

module.exports.getTarget = (config, next) ->
    
    schema =
        properties:
            dataset:
                description: "Data set to load #{list(config.datasets)}"
                type: 'string'
                required: true
                default: config.datasets[0]
                conform: (value) -> config.datasets[value]
            env:
                description: "Target environment #{list(config.envs)}"
                type: 'string'
                required: true
                default: config.envs[0]
                conform: (value) -> config.envs[value]
            username:
                description: 'Username'
                type: 'string'
                required: false
            password:
                description: 'Password'
                type: 'string'
                required: false
                hidden: true
    
    prompt.start()
    prompt.get schema, next

list = (obj) ->
    '[' + _.keys(obj).join(',') + ']'
