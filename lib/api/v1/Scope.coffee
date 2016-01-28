Boom = require 'boom'
Joi = require 'joi'

POSTGRES_UNIQUE_VIOLATION = '23505'

module.exports = (server) ->
  Scope = server.plugins['bookshelf']['Scope']
  server.route
    method: 'GET'
    path: '/api/v1/scope'
    config:
      auth:
        scope: [ 'admin' ]
    handler: (request, reply) ->
      Scope.collection().fetch()
      .then (scopes) ->
        reply scopes
      .catch (error) ->
        console.error error
        reply Boom.badImplementation()
  server.route
    method: 'GET'
    path: '/api/v1/scope/{id}'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        params:
          id: Joi.number().integer().min(1).required()
    handler: (request, reply) ->
      Scope.where
        id: request.params.id
      .fetch()
      .then (scope) ->
        if account
          reply scope
        else
          reply Boom.notFound()
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error
  server.route
    method: 'POST'
    path: '/api/v1/scope'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        payload:
          key: Joi.string().required()
          description: Joi.string().required()
    handler: (request, reply) ->
      new Scope
        key: request.payload.key
        description: hash.description
      .save()
      .then (scope) ->
        reply scope
      .catch Scope.NoRowsUpdatedError, (error) ->
        reply Boom.badImplementation()
        console.error error
      .catch (error) ->
        if error.code == POSTGRES_UNIQUE_VIOLATION
          reply Boom.conflict()
        else
          reply Boom.badImplementation()
          console.error error
  server.route
    method: 'PUT'
    path: '/api/v1/scope/{id}'
    config:
      auth:
        scope: [ 'admin' ]
      validate:
        params:
          id: Joi.number().integer().min(1).required()
        payload:
          key: Joi.string().required()
          description: Joi.string().required()
    handler: (request, reply) ->
      Scope.forge
        id: request.params.id
        key: request.payload.key
        description: request.payload.description
      .save()
      .then (scope) ->
        reply scope
      .catch Scope.NoRowsUpdatedError, (err) ->
        reply Boom.notFound()
      .catch (err) ->
        reply Boom.badImplementation()
        console.error err
