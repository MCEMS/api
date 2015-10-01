require 'coffee-script'

Joi = require 'joi'
Bcrypt = require 'bcrypt'
JWS = require 'jws'
Boom = require 'boom'

JWS_ALGORITHM = 'HS256'
JWS_SECRET = process.env.TOKEN_SIGNING_SECRET or '123456'
JWS_TTL = 3600 # seconds (one hour)

generateToken = (account) ->
  current_time = Math.floor(new Date().getTime() / 1000)
  expires_at = current_time + JWS_TTL
  signature = JWS.sign
    header:
      alg: JWS_ALGORITHM
    payload:
      u: account.username
      x: expires_at
    secret: JWS_SECRET
  reply =
    token: signature
    expires: expires_at
  reply

module.exports = (server) ->
  Account = server.plugins['bookshelf']['Account']

  server.route
    method: 'POST'
    path: '/auth/key'
    config:
      validate:
        payload:
          username: Joi.string().required()
          password: Joi.string().required()
    handler: (request, reply) ->
      new Account
        username: request.payload.username
      .fetch()
      .then (acc) ->
        if acc
          Bcrypt.compare request.payload.password, acc.get('password'), (err, valid) ->
            if err
              reply Boom.badImplementation()
              console.error err
            else
              if valid
                reply generateToken(acc)
              else
                reply Boom.unauthorized()
        else
          reply Boom.unauthorized()
      .catch (err) ->
        reply Boom.badImplementation()
        console.error err
