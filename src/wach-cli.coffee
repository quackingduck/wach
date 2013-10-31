path = require 'path'
fs = require 'fs'
spawn = require('child_process').spawn
minimatch = require 'minimatch'

{parseArgs,npmVersion,log,localTime,exit,matchesGlobs} = require './support'
watch = require './wach'

@run = (rawArgs) ->
  args = parseArgs rawArgs
  {help,version,command,only} = parseArgs rawArgs

  exit 0, usage if args.help?
  exit 0, npmVersion() if args.version?

  exit 1, usage unless args.command?

  log.info "Will run: #{args.command}"

  if args.only.length is 0
    log.info "when any files added or updated"
  else
    log.info "when files matching {#{args.only.join(',')}} added or updated"
  if args.except.length isnt 0
    log.info "except those matching {#{args.except.join(',')}}"

  commandRunning = no

  cwd = process.cwd()

  watch cwd, (changedPath) ->
    changedPath = path.relative cwd, changedPath

    # don't start a new run if the last one hasn't finished
    return if commandRunning

    # do nothing for deletes
    return unless fs.existsSync changedPath
    # do nothing for ignored paths
    return if (args.only.length   isnt 0) and (not matchesGlobs changedPath, args.only)
    return if (args.except.length isnt 0) and (    matchesGlobs changedPath, args.except)

    commandWithPathSubsitution = substitutePath(args.command, changedPath)

    log.info ""
    log.info "changed: #{changedPath} (#{localTime()})"
    log.info "running: #{commandWithPathSubsitution}"
    log.info ""

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

usage = """
Run a command every when file changes occur in the current directory. If
the command you want to run is a long running process like a web server
see `wachs`

Usage:
  wach [options] <command>

Required:
  <command>
    Run every time an update occurs in the directory being monitored.
    If the command includes `{}` it will be subsituted for the path that changed.

Options:
  -o|--only <globs>
    Only run <command> when the path that changed matches <globs>.

  -e|--except <globs>
    Only run <command> when the path that changed doesn't match <globs>.

  Quote the <globs> ("*.c") or add a trailing comma (*.c,) to prevent your shell from
  automatically expanding  them.

Examples:
  wach make
  wach -o *.c, make
  wach -o *.coffee, coffee {}
  TEST_DIR=generators wach -o **/*.rb, bundle exec rake test
"""
