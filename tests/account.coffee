require 'coffee-script'

should = require 'should'
utils = require './utils'
Account = utils.Account
server = utils.server

describe 'Account', ->

  beforeEach (done) ->
    utils.knex('Account').delete()
    .then ->
      done()
    .catch ->
      done()

  describe 'List', ->
    it 'returns an empty array when there are no accounts', (done) ->
      request =
        method: 'GET'
        url: '/api/v1/account'
      server.inject request, (response) ->
        response.statusCode.should.equal 200
        JSON.parse(response.payload).should.be.an.Array
        JSON.parse(response.payload).should.be.empty()
        done()

    it 'creates and reads an account', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'test'
          password: 'letmein'
      server.inject req1, (res1) ->
        req2 =
          method: 'GET'
          url: '/api/v1/account'
        server.inject req2, (res2) ->
          p2 = JSON.parse res2.payload
          res2.statusCode.should.equal 200
          p2.should.be.an.Array
          p2.length.should.equal 1
          p2[0].should.be.an.Object
          p2[0].should.have.keys 'id', 'username'
          p2[0].should.not.have.keys 'password'
          done()

  describe 'Create', ->
    it 'creates and reads an account', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'test'
          password: 'letmein'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        res1.statusCode.should.equal 200
        p1.should.be.an.Object
        p1.should.have.keys 'id', 'username'
        p1.should.not.have.keys 'password'
        p1.username.should.equal 'test'
        req2 =
          method: 'GET'
          url: '/api/v1/account/' + p1.id
        server.inject req2, (res2) ->
          p2 = JSON.parse res2.payload
          res2.statusCode.should.equal 200
          p2.should.be.an.Object
          p2.should.have.keys 'id', 'username'
          p2.should.not.have.keys 'password'
          p2.username.should.equal 'test'
          p2.id.should.equal p1.id
          done()

    it 'does not create an when parameters are invalid', (done) ->
      req =
        method: 'POST'
        url: '/api/v1/account'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

    it 'does not allow duplicate usernames to be created', (done) ->
      req =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'test'
          password: 'pw1'
      server.inject req, (res1) ->
        server.inject req, (res2) ->
          res1.statusCode.should.equal 200
          res2.statusCode.should.equal 409 # Conflict
          done()

  describe 'Read', ->
    it 'sends 404 when requested account is not found', (done) ->
      req =
        method: 'GET'
        url: '/api/v1/account/1'
      server.inject req, (res) ->
        res.statusCode.should.equal 404 # Not Found
        done()

    it 'sends 400 when requested account is invalid', (done) ->
      req =
        method: 'GET'
        url: '/api/v1/account/notreal'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

  describe 'Update', ->
    it 'updates an account', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'test'
          password: 'letmein'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'PUT'
          url: '/api/v1/account/' + p1.id
          payload:
            username: 'test2'
            password: 'letuin'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 200
          p2 = JSON.parse res2.payload
          p2.should.be.an.Object
          p2.should.have.keys 'id', 'username'
          p2.should.not.have.keys 'password'
          p2.username.should.equal 'test2'
          done()

    it 'does not update an account for invalid payload', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'test'
          password: 'letmein'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'PUT'
          url: '/api/v1/account/' + p1.id
          payload:
            username: 'no-password'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 400 # Bad request
          done()

    it 'does not update an account for invalid ID', (done) ->
      req =
        method: 'PUT'
        url: '/api/v1/account/aaa'
        payload:
          username: 'usr'
          password: 'pass'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad request
        done()

    it 'does not update a non-existent account', (done) ->
      req =
        method: 'PUT'
        url: '/api/v1/account/1'
        payload:
          username: 'user'
          password: 'pass'
      server.inject req, (res) ->
        res.statusCode.should.equal 404
        req2 =
          method: 'GET'
          url: '/api/v1/account/1'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 404
          done()

  describe 'Delete', ->
    it 'deletes an account', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/account'
        payload:
          username: 'user'
          password: 'letmein'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'DELETE'
          url: '/api/v1/account/' + p1.id
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 204 # No Content
          res2.payload.should.be.empty()
          req3 =
            method: 'GET'
            url: '/api/v1/account'
          server.inject req3, (res3) ->
            res3.statusCode.should.equal 200
            JSON.parse(res3.payload).should.be.an.Array
            JSON.parse(res3.payload).should.be.empty()
            done()

    it 'returns an error when trying to delete an invalid account', (done) ->
      req =
        method: 'DELETE'
        url: '/api/v1/account/not-real'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

    it 'returns an error when deleting a non-existent account', (done) ->
      req =
        method: 'DELETE'
        url: '/api/v1/account/1'
      server.inject req, (res) ->
        res.statusCode.should.equal 404 # Not Found
        done()
