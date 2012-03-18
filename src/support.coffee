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
