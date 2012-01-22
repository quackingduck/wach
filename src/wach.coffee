spawn = require('child_process').spawn

# Calls `callback` with a path every time a filesystem event occurs in `dir`,
# e.g.:
#
#     watch '.', (path) -> console.log "something happened to #{path}!"
#
# This function is a thin wrapper over the `wach-watchdir` executable which
# does the heavy lifting. It hooks into the OS's file events system and writes
# the paths where events occur to stdout.
module.exports = (dir, callback) ->
  watcherProcess = spawn "#{__dirname}/../bin/wach-watchdir", [dir]

  watcherProcess.stdout.on 'data', (data) ->
    callback(path) for path in parseData(data.toString())

  # The process runs until killed so if it exits it means there was an error
  watcherProcess.on 'exit', (code) ->
    process.stderr.write """
    Unable to start watcher for "#{dir}".
    This is probably a bug.
    """ + '\n'

# `wach-watchdir` writes one or more paths separated by newlines to its stdout
# stream, e.g.:
#
#     /Users/bob/someproject/foo.c
#     /Users/bob/someproject/bar.c
#
# We parse this into an array of path strings
parseData = (str) -> str.split('\n')[0...-1]
