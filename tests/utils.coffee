require 'coffee-script'

server = require '../lib/server'

module.exports.server = server
module.exports.bookshelf = server.plugins['bookshelf']['bookshelf']
module.exports.knex = module.exports.bookshelf.knex
module.exports.Account = server.plugins['bookshelf']['Account']
module.exports.Person = server.plugins['bookshelf']['Person']
