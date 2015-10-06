require 'coffee-script'
env = process.env.NODE_ENV or 'development'
config = require('../../knexfile')[env]

knex = require('knex')(config)
bookshelf = require('bookshelf')(knex)

Person = bookshelf.Model.extend
  tableName: 'Person'

Scope = bookshelf.Model.extend
  tableName: 'Scope'

Account = bookshelf.Model.extend
  tableName: 'Account'
  scopes: ->
    this.belongsToMany Scope, 'Account_Scope', 'account_id', 'scope_id'
  person: ->
    this.belongsTo Person, 'APIUser', 'account_id', 'person_id'

module.exports.register = (server, options, next) ->
  server.expose 'bookshelf', bookshelf
  server.expose 'Person', Person
  server.expose 'Scope', Scope
  server.expose 'Account', Account
  next()

module.exports.register.attributes =
  name: 'bookshelf'
  version: '1.0.0'

