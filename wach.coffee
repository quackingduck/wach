spawn = require('child_process').spawn

@watch = (dir, callback) ->

  # Wraps the `watchdir` command which does the heavy lifting. It hooks into
  # the Lion's file events system and writes the path of change (file or dir)
  # to stdout.
  watcherProcess = spawn('./watchdir', [__dirname]);

  watcherProcess.stdout.on 'data', (data) ->
    changedPaths = data.toString().split('\n')[0...-1]
    callback(path) for path in changedPaths

  # The process runs until killed so if it exits it means there was an error
  watcherProcess.on 'exit', (code) ->
    process.stderr.write """
    Unable to start watcher for "#{__dirname}".
    This is probably a bug.
    """ + '\n'

# ---

