path = require 'path'
spawn = require('child_process').spawn
minimatch = require 'minimatch'

support = require './support'
watch = require './wach'

@run = (args) ->
  {help,version,command,only} = support.parseArgs args

  exit 0, usage if help?
  exit 0, npmVersion() if version?

  exit 1, usage unless command?

  logInfo "Will run: #{command}"
  if only.length is 0
    logInfo "when any files added or updated."
  else
    logInfo "when files matching {#{only.join(',')}} added or updated"

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

# ---

substitutePath = (command, path) ->
  command.replace '{}', path

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

exit = (status, message) ->
  console.log(message) if message?
  process.exit status

npmVersion = ->
  JSON.parse(require('fs').readFileSync(__dirname + '/../package.json')).
  version

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
@_test = {passesGlobFilters}

