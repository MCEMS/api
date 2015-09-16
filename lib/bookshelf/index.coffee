require 'coffee-script'
env = process.env.NODE_ENV or 'development'
config = require('../../knexfile')[env]

knex = require('knex')(config)
bookshelf = require('bookshelf')(knex)

Person = bookshelf.Model.extend
  tableName: 'Person'

module.exports.register = (server, options, next) ->
  server.expose 'bookshelf', bookshelf
  server.expose 'Person', Person
  next()

module.exports.register.attributes =
  name: 'bookshelf'
  version: '1.0.0'

