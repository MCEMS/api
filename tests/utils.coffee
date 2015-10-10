require 'coffee-script'

server = require '../lib/server'
AuthUtils = require '../lib/auth/utils'

module.exports.server = server
module.exports.bookshelf = server.plugins['bookshelf']['bookshelf']
module.exports.knex = module.exports.bookshelf.knex
module.exports.Account = server.plugins['bookshelf']['Account']
module.exports.Person = server.plugins['bookshelf']['Person']
module.exports.Alert = require '../lib/api/v1/Alert'
module.exports.credentials =
  id: 0
  scope: [ 'admin', 'send_alert' ]
