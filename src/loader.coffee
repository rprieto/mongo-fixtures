fs = require 'fs'
wrench = require 'wrench'

module.exports.load = (path) ->
    if fs.existsSync("#{path}.coffee")
        loadFile path
    else
        loadFolder path

loadFile = (path) ->
    console.log "- Loading #{path}"
    require path

loadFolder = (path) ->
    console.log "- Loading #{path}"
    items = []
    files = wrench.readdirSyncRecursive path
    files.forEach (file) ->
        if file.match(/coffee$/)
            item = require "#{path}/#{file}"
            items.push item
    items
