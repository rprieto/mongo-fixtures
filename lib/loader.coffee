fs = require 'fs'
wrench = require 'wrench'

module.exports.load = (path, quiet) ->
    if fs.existsSync("#{path}.coffee")
        loadFile path, quiet
    else
        loadFolder path, quiet

loadFile = (path, quiet) ->
    console.log "- Loading #{path}" unless quiet
    require path

loadFolder = (path) ->
    console.log "- Loading #{path}" unless quiet
    items = []
    files = wrench.readdirSyncRecursive path
    files.forEach (file) ->
        if file.match(/coffee$/)
            item = require "#{path}/#{file}"
            items.push item
    items
