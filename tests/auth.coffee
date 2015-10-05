require 'coffee-script'

should = require 'should'
utils = require './utils'

describe 'Authorization', ->
  beforeEach (done) ->
    utils.knex('Account').delete()
    .then ->
      utils.server.inject
        method: 'POST'
        url: '/api/v1/account'
        credentials: utils.credentials
        payload:
          username: 'test'
          password: 'letmein'
      , (response) ->
        done()
    .catch ->
      done()

  it 'generates a token for valid account', (done) ->
    utils.server.inject
      method: 'POST'
      url: '/auth/key'
      payload:
        username: 'test'
        password: 'letmein'
    , (response) ->
      payload = JSON.parse response.payload
      response.statusCode.should.equal 200
      payload.should.be.an.Object
      payload.should.have.keys 'token', 'scope', 'expiresInSeconds'
      done()

  it 'does not generates a token for invalid account', (done) ->
    utils.server.inject
      method: 'POST'
      url: '/auth/key'
      payload:
        username: 'test'
        password: 'letmeout'
    , (response) ->
      response.statusCode.should.equal 401
      done()

  it 'sends 400 for bad request', (done) ->
    utils.server.inject
      method: 'POST'
      url: '/auth/key'
    , (response) ->
      response.statusCode.should.equal 400 # bad request
      done()
