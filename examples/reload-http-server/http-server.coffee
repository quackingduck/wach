http = require 'http'

server = http.createServer (req, res) ->
  res.end "hello chi.js()\n"

server.listen 2121, -> console.log "listening on localhost:2121"
