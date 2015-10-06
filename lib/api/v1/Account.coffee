Boom = require 'boom'
Joi = require 'joi'
bcrypt = require 'bcrypt'

BCRYPT_ROUNDS = 12
POSTGRES_UNIQUE_VIOLATION = '23505'

module.exports = (server) ->

  Account = server.plugins['bookshelf']['Account']

  # Get a list (jsonarray) of accounts
  server.route
    method: 'GET'
    path: '/api/v1/account'
    config:
      auth:
        scope: [ 'admin' ]
    handler: (request, reply) ->
      Account.collection().fetch()
      .then (accounts) ->
        reply accounts.map((acct) ->
          acct.omit 'password'
        )
      .catch (error) ->
        console.error error
        reply Boom.badImplementation()

  # Get one account by id
  server.route
    method: 'GET'
    path: '/api/v1/account/{id}'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        params:
          id: Joi.number().integer().min(1).required()
    handler: (request, reply) ->
      Account.where
        id: request.params.id
      .fetch()
      .then (account) ->
        if account
          reply account.omit('password')
        else
          reply Boom.notFound()
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error

  # Add a new account
  server.route
    method: 'POST'
    path: '/api/v1/account'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        payload:
          username: Joi.string().required()
          password: Joi.string().required()
    handler: (request, reply) ->
      bcrypt.genSalt BCRYPT_ROUNDS, (err, salt) ->
        if err
          reply Boom.badImplementation()
          console.error err
        else
          bcrypt.hash request.payload.password, salt, (err, hash) ->
            if err
              reply Boom.badImplementation()
              console.error err
            else
              new Account
                username: request.payload.username
                password: hash
              .save()
              .then (account) ->
                reply account.omit('password')
              .catch Account.NoRowsUpdatedError, (error) ->
                reply Boom.badImplementation()
                console.error error
              .catch (error) ->
                if error.code == POSTGRES_UNIQUE_VIOLATION
                  reply Boom.conflict()
                else
                  reply Boom.badImplementation()
                  console.error error

  # Delete an account by id
  server.route
    method: 'DELETE'
    path: '/api/v1/account/{id}'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        params:
          id: Joi.number().integer().min(1).required()
    handler: (request, reply) ->
      new Account
        id: request.params.id
      .destroy({ require: true })
      .then ->
        reply().code 204 # No Content
      .catch Account.NoRowsDeletedError, (error) ->
        reply Boom.notFound()
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error

  # Select an account by id and update
  server.route
    method: 'PUT'
    path: '/api/v1/account/{id}'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        params:
          id: Joi.number().integer().min(1).required()
        payload:
          username: Joi.string().required()
          password: Joi.string().required()
    handler: (request, reply) ->
      bcrypt.genSalt BCRYPT_ROUNDS, (err, salt) ->
        if err
          reply Boom.badImplementation()
        else
          bcrypt.hash request.payload.password, salt, (err, hash) ->
            if err
              reply Boom.badImplementation()
              console.error err
            else
              Account.forge
                id: request.params.id
                username: request.payload.username
                password: hash
              .save()
              .then (account) ->
                reply account.omit('password')
              .catch Account.NoRowsUpdatedError, (err) ->
                reply Boom.notFound()
              .catch (err) ->
                reply Boom.badImplementation()
                console.error err
