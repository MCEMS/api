require 'coffee-script'

server = require './server'

server.start ->
  console.log 'Server running!'

