require 'coffee-script'

Hapi = require 'hapi'
Path = require 'path'

server = new Hapi.Server()
server.connection
  port: process.env.PORT || 3000

server.register require('inert'), (err) ->
  console.error 'Error registering inert:', err if err
  server.route
    method: 'GET'
    path: '/client/v1.js'
    config:
      auth: false
    handler:
      file: Path.join __dirname, 'static/client/v1.js'

server.register require('./bookshelf'), (err) ->
  console.error 'Error registering bookshelf:', err if err
  require('./auth/routes')(server)
  require('./api/v1')(server)

module.exports = server
