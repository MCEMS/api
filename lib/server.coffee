require 'coffee-script'

Hapi = require 'hapi'

server = new Hapi.Server()
server.connection
  port: process.env.PORT || 3000

server.register [require('./bookshelf'), require('./redis'), require('./active911')], (err) ->
  console.error 'Error registering plugin:', err if err
  require('./auth/routes')(server)
  require('./api/v1')(server)

server.ext('onPreResponse', require('hapi-cors-headers'))

module.exports = server
