require 'coffee-script'
Good = require 'good'

server = require './server'

server.register
  register: Good
  options:
    reporters: [{
      reporter: require 'good-console'
      events:
        response: '*'
        log: '*'
    }]
, (err) ->
  console.error 'Error registering Good:', err if err

server.start ->
  console.log 'Server running!'
