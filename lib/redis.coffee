require 'coffee-script'
redis = require 'redis'

module.exports.register = (server, options, next) ->
  if process.env.REDIS_URL
    client = redis.createClient(process.env.REDIS_URL)
  else if process.env.NODE_ENV == 'travis'
    client = redis.createClient()
  else
    client = redis.createClient('6379', 'redis')
  server.expose 'redis', client
  next()

module.exports.register.attributes =
  name: 'redis'
  version: '1.0.0'

