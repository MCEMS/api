require 'coffee-script'
Active911 = require 'active911'

module.exports.register = (server, options, next) ->
  #client = new Active911.RefreshClient(process.env.ACTIVE911_REFRESH_TOKEN)
  client = new Active911.RefreshClient('a358d2953f61cd7ca1a6bc0c7819e85d201338b1')
  server.expose 'active911', client
  next()

module.exports.register.attributes =
  name: 'active911'
  version: '1.0.0'

