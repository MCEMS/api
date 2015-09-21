Boom = require 'boom'
Joi = require 'joi'

module.exports = (server) ->

  Person = server.plugins['bookshelf']['Person']

  # Get people
  server.route
    method: 'GET'
    path: '/api/v1/person'
    handler: (request, reply) ->
      Person.collection().fetch()
      .then (people) ->
        reply people
      .catch (error) ->
        console.error error
        reply Boom.badImplementation()

  server.route
    method: 'GET'
    path: '/api/v1/person/{id}'
    config:
      validate:
        params:
          id: Joi.number().integer().min(1).required()
    handler: (request, reply) ->
      Person.where
        id: request.params.id
      .fetch()
      .then (person) ->
        if person
          reply person
        else
          reply Boom.notFound()
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error

  server.route
    method: 'POST'
    path: '/api/v1/person'
    config:
      validate:
        payload:
          first_name: Joi.string().required()
          last_name: Joi.string().required()
    handler: (request, reply) ->
      new Person
        first_name: request.payload.first_name
        last_name: request.payload.last_name
      .save()
      .then (person) ->
        reply person
      .catch Person.NoRowsUpdatedError, (error) ->
        reply Boom.badImplementation()
        console.error error
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error

  server.route
    method: 'DELETE'
    path: '/api/v1/person/{id}'
    config:
      validate:
        params:
          id: Joi.number().integer().min(1).required()
    handler: (request, reply) ->
      new Person
        id: request.params.id
      .destroy({ require: true })
      .then ->
        reply().code 204 # No Content
      .catch Person.NoRowsDeletedError, (error) ->
        reply Boom.notFound()
      .catch (error) ->
        reply Boom.badImplementation()
        console.error error

  server.route
    method: 'PUT'
    path: '/api/v1/person/{id}'
    config:
      validate:
        params:
          id: Joi.number().integer().min(1).required()
        payload:
          first_name: Joi.string().required()
          last_name: Joi.string().required()
    handler: (request, reply) ->
      Person.forge
        id: request.params.id
        first_name: request.payload.first_name
        last_name: request.payload.last_name
      .save()
      .then (person) ->
        reply person
      .catch Person.NoRowsUpdatedError, (error) ->
        reply Boom.notFound()
      .catch (error) ->
        console.error error
        reply Boom.badImplementation()
