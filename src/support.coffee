@parseArgs = (raw) ->
  first = raw[0]
  return { help: yes }    if match first, '--help', '-h'
  return { version: yes } if match first, '--version', '-v'

  command = [] ; only = [] ; except = []

  raw = raw.slice() # copy array
  while arg = raw.shift()
    switch arg
      when '--only',   '-o' then only = parseCommaSeparatedAndRemoveBlanks raw.shift()
      when '--except', '-e' then except = parseCommaSeparatedAndRemoveBlanks raw.shift()
      else command.push arg

  command = if command.length isnt 0 then command.join ' ' else null
  {command,only,except}

parseCommaSeparatedAndRemoveBlanks = (str) -> (i for i in str.split(',') when i isnt '')
match = (val,values...) -> values.indexOf(val) >= 0

# ---

@log = (args...) -> console.log args...
@log.info = (msg) ->
  # 0;38;5 = xterm color, 246 = a light gray
  console.error termColorWrap '0;38;5;246', "- #{msg}"

termColorWrap = (code, str) -> termColor(code) + str + termColor()
termColor = (code = '') -> '\x1B' + '[' + code + 'm'

# ---

minimatch = require 'minimatch'

@matchesGlobs = (path, globs) ->
  matches = (match for glob in globs when minimatch path, glob)
  matches.length isnt 0

# ---

@localTime = -> (new Date).toTimeString().split(' ')[0]

# ---

@exit = (status, message) ->
  console.log(message) if message?
  process.exit status

# ---

@npmVersion = ->
  JSON.parse(require('fs').readFileSync(__dirname + '/../package.json')).
  version
