require 'coffee-script'

Joi = require 'joi'
Bcrypt = require 'bcrypt'
JWT = require 'jsonwebtoken'
Boom = require 'boom'
AuthUtils = require './utils'

module.exports = (server) ->
  Account = server.plugins['bookshelf']['Account']

  server.register require('hapi-auth-jwt'), (err) ->
    console.error err if err
    server.auth.strategy 'token', 'jwt', 'required',
      key: AuthUtils.JWS_SECRET
      validateFunc: AuthUtils.validateToken

  server.route
    method: 'POST'
    path: '/auth/key'
    config:
      auth: false
      validate:
        payload:
          username: Joi.string().required()
          password: Joi.string().required()
    handler: (request, reply) ->
      new Account
        username: request.payload.username
      .fetch
        withRelated: ['scopes']
      .then (acc) ->
        if acc
          Bcrypt.compare request.payload.password, acc.get('password'), (err, valid) ->
            if err
              reply Boom.badImplementation()
              console.error err
            else
              if valid
                reply AuthUtils.generateToken(acc, request)
              else
                reply Boom.unauthorized()
        else
          reply Boom.unauthorized()
      .catch (err) ->
        reply Boom.badImplementation()
        console.error err
