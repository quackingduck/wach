http = require 'http'

server = http.createServer (req, res) ->
  res.end "hai\n"

server.listen 2121, -> console.log "listening on localhost:2121"
