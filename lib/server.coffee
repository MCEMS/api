require 'coffee-script'

Hapi = require 'hapi'

server = new Hapi.Server()
server.connection
  port: process.env.PORT || 3000

server.register require('./bookshelf'), (err) ->
  console.error 'Error registering bookshelf:', err if err
  require('./api/v1')(server)
  require('./auth')(server)

module.exports = server

