require 'coffee-script'
Active911 = require 'active911'

module.exports.register = (server, options, next) ->
  client = new Active911.RefreshClient(process.env.ACTIVE911_REFRESH_TOKEN)
  server.expose 'active911', client
  next()

module.exports.register.attributes =
  name: 'active911'
  version: '1.0.0'

