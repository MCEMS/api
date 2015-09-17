Boom = require 'boom'

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

