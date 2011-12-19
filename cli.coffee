# todo, validate args

path = require 'path'
spawn = require('child_process').spawn
minimatch = require 'minimatch'
watch = require('./wach').watch

run = (args) ->
  {help,command,only} = parseArgs args

  if help
    console.log usage
    process.exit 0
  if command.length is 0
    console.log usage
    process.exit 1

  logInfo "Will run: #{command}"
  logInfo "when any files added or updated."
  logInfo()

  commandRunning = no

  watch __dirname, (changedPath) ->
    changedPath = path.relative __dirname, changedPath

    # Just the one instance thanks
    return if commandRunning

    # Ignore the deletes
    return unless path.existsSync changedPath

    # changedPath must pass only filters
    passesOnlyFilters = yes
    if only.length > 0
      passesOnlyFilters = no
      for exp in only
        if minimatch changedPath, exp
          passesOnlyFilters = yes

    return unless passesOnlyFilters

    logInfo "changed: #{changedPath} "
    logInfo "running command"
    logInfo()

    # Run command in subshell
    # todo: command '@' substitution
    child = spawn 'bash', ['-c', command ]
    commandRunning = yes
    child.stdout.pipe process.stdout
    child.on 'exit', (code) ->
      commandRunning = no
      # todo: report status
      logInfo()
      logInfo "command exited"
      logInfo()

parseArgs = (raw) ->
  help = no; command = []; only = []
  while arg = raw.shift()
    switch arg
      when '--help', '-h' then help = yes
      when '--only', '-o' then only = (i for i in raw.shift().split(',') when i isnt '' )
      else command.push arg
  command.join ' '
  {help,command,only}

logInfo = (msg) ->
  console.log if msg? then "- #{msg}" else ''


usage = """
Usage:
  wach [options] <command>

Required:
  <command>
    Run every time an update occurs in the directory being monitored.
    The `@` will be subsituted with the path that changed.

Options:
  -o|--only <glob>
    Only run <command> when the path that changed matches <glob>. Quote the
    glob or add a trailing comma to prevent your shell from automatically
    expanding it.

Examples:
  wach make
  wach -o *.c, make
  wach -o *.coffee, coffee @
  TEST_DIR=generators wach -o **/*.rb, bundle exec rake test
"""

# ---

run process.argv.slice 2
