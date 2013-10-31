path = require 'path'
fs = require 'fs'
{spawn} = require 'child_process'

{parseArgs,log,matchesGlobs,localTime,exit,npmVersion} = require './support'
watch = require './wach'

@run = (rawArgs) ->
  args = parseArgs rawArgs

  exit 0, usage if args.help?
  exit 0, npmVersion() if args.version?

  exit 1, usage unless args.command?

  log.info "Will kill and restart: #{args.command}"

  if args.only.length is 0
    log.info "when any files added or updated"
  else
    log.info "when files matching {#{args.only.join(',')}} added or updated"
  if args.except.length isnt 0
    log.info "except those matching {#{args.except.join(',')}}"

  child = null
  shouldRestart = no
  diedOnItsOwn = no

  runCommand = ->
    log.info "starting ..."
    child = spawn 'sh', ['-c', "exec #{args.command}"]
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    child.on 'exit', (code) ->
      if shouldRestart
        log.info "killed"
        runCommand()
        shouldRestart = no
      else
        log.info "process exited by itself, crash?"
        diedOnItsOwn = yes

  runCommand()

  cwd = process.cwd()

  watch cwd, (changedPath) ->
    changedPath = path.relative cwd, changedPath

    # do nothing for deletes
    return unless fs.existsSync changedPath
    # do nothing for ignored paths
    return if (args.only.length   isnt 0) and (not matchesGlobs changedPath, args.only)
    return if (args.except.length isnt 0) and (    matchesGlobs changedPath, args.except)

    shouldRestart = yes

    log.info ""
    log.info "changed: #{changedPath} (#{localTime()})"

    log.info "killin ..."
    child.kill()
    if diedOnItsOwn
      runCommand()
      diedOnItsOwn = no

usage = """
The "server" version of `wach`. Pass it a command to start a long running
process (such as a web server) and it will run that process then monitor
the current directory for file modifications. When a file changes it will
automatically restart the process.

Usage:
  wachs [options] <command>

Required:
  <command>
    The command to restart every time an update occurs in the directory being monitored.

Options:
  -o|--only <globs>
    Only run <command> when the path that changed matches <globs>.

  -e|--except <globs>
    Only run <command> when the path that changed doesn't match <globs>.

  Quote the <globs> ("*.c") or add a trailing comma (*.c,) to prevent your shell from
  automatically expanding  them.

Examples:
  wachs node server.js
  wachs coffee server.coffee
  wachs ruby sinatra-app.rb
  wachs -o server/*.js, node server.js
"""
