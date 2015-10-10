require 'coffee-script'

module.exports = (server) ->
  require('./Person')(server)
  require('./Account')(server)
  require('./Alert').addRoutes server
