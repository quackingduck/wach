path = require 'path'
spawn = require('child_process').spawn
minimatch = require 'minimatch'
watch = require './wach'

@run = (args) ->
  {help,command,only} = parseArgs args

  if help
    console.log usage
    process.exit 0
  if command.length is 0
    console.log usage
    process.exit 1

  logInfo "Will run: #{command}"
  logInfo "when any files added or updated."

  commandRunning = no

  watch process.cwd(), (changedPath) ->
    changedPath = path.relative process.cwd(), changedPath

    return if commandRunning
    return unless path.existsSync changedPath
    return unless passesGlobFilters changedPath, only

    commandWithPathSubsitution = substitutePath(command, changedPath)

    logInfo ""
    logInfo "changed: #{changedPath} (#{localTime()})"
    logInfo "running: #{commandWithPathSubsitution}"
    logInfo ""

    # Run command in subshell
    child = spawn 'sh', ['-c', commandWithPathSubsitution ]
    commandRunning = yes
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    child.on 'exit', (code) ->
      commandRunning = no

parseArgs = (raw) ->
  help = no; command = []; only = []
  while arg = raw.shift()
    switch arg
      when '--help', '-h' then help = yes
      when '--only', '-o' then only = (i for i in raw.shift().split(',') when i isnt '' )
      when '--version' then printVersionAndExit()
      else command.push arg
  command = command.join ' '
  {help,command,only}

# todo: don't substitute '@' if it's in the middle of a word (e.g.
# foo@bar.com)
substitutePath = (command, path) ->
  command.replace '@', path

passesGlobFilters = (path, filters) ->
  if filters.length is 0
    yes
  else
    pass = no
    for exp in filters
      if minimatch path, exp
        pass = yes
    pass

logInfo = (msg) ->
  # 0;38;5 = xterm color, 246 = a light gray
  console.error termColorWrap '0;38;5;246', "- #{msg}"

termColorWrap = (code, str) -> termColor(code) + str + termColor()
termColor = (code = '') -> '\033' + '[' + code + 'm'

localTime = -> (new Date).toTimeString().split(' ')[0]

printVersionAndExit = ->
  console.log(
    JSON.parse(require('fs').readFileSync(__dirname + '/../package.json')).
    version
  )
  process.exit()

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

# Expose some internals for testing
@_test = {passesGlobFilters,parseArgs}

