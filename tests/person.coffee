require 'coffee-script'

should = require 'should'
server = require '../lib/server'

describe 'Person', ->
  Person = server.plugins['bookshelf']['Person']
  bookshelf = server.plugins['bookshelf']['bookshelf']

  before (done) ->
    bookshelf.knex.migrate.latest()
    .then ->
      done()
    .catch ->
      done()

  beforeEach (done) ->
    bookshelf.knex('Person').truncate()
    .then ->
      done()
    .catch ->
      done()

  after ->
    bookshelf.knex.destroy()

  describe 'List', ->
    it 'returns an empty array when there are no people', (done) ->
      request =
        method: 'GET'
        url: '/api/v1/person'
      server.inject request, (response) ->
        response.statusCode.should.equal 200
        JSON.parse(response.payload).should.be.an.Array
        JSON.parse(response.payload).should.be.empty()
        done()

    it 'returns an array containing a person', (done) ->
      new Person
        first_name: 'Malcolm'
        last_name: 'Reynolds'
      .save()
      .then (person) ->
        request =
          method: 'GET'
          url: '/api/v1/person'
        server.inject request, (response) ->
          p = JSON.parse(response.payload)
          response.statusCode.should.equal 200
          p.should.be.an.Array
          p.should.not.be.empty()
          p.should.have.length 1
          p[0].should.be.an.Object
          p[0].should.have.keys 'id', 'first_name', 'last_name'
          done()
      .catch ->
        should.fail()

  describe 'Create', ->
    it 'creates and reads a person', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/person'
        payload:
          first_name: 'Bob'
          last_name: 'Jones'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        res1.statusCode.should.equal 200
        p1.should.be.an.Object
        p1.should.have.keys 'id', 'first_name', 'last_name'
        p1.first_name.should.equal 'Bob'
        p1.last_name.should.equal 'Jones'
        req2 =
          method: 'GET'
          url: '/api/v1/person/' + p1.id
        server.inject req2, (res2) ->
          p2 = JSON.parse res2.payload
          res2.statusCode.should.equal 200
          p2.should.be.an.Object
          p1.should.have.keys 'id', 'first_name', 'last_name'
          p2.first_name.should.equal 'Bob'
          p2.last_name.should.equal 'Jones'
          p2.id.should.equal p1.id
          done()

    it 'does not create a person when parameters are invalid', (done) ->
      req =
        method: 'POST'
        url: '/api/v1/person'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

  describe 'Read', ->
    it 'sends 404 when requested person is not found', (done) ->
      req =
        method: 'GET'
        url: '/api/v1/person/1'
      server.inject req, (res) ->
        res.statusCode.should.equal 404 # Not Found
        done()

    it 'sends 400 when requested person is invalid', (done) ->
      req =
        method: 'GET'
        url: '/api/v1/person/notaperson'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

  describe 'Update', ->
    it 'updates a person', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/person'
        payload:
          first_name: 'Bob'
          last_name: 'Jones'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'PUT'
          url: '/api/v1/person/' + p1.id
          payload:
            first_name: 'Amy'
            last_name: 'Smith'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 200
          p2 = JSON.parse res2.payload
          p2.should.be.an.Object
          p2.should.have.keys 'id', 'first_name', 'last_name'
          p2.first_name.should.equal 'Amy'
          p2.last_name.should.equal 'Smith'
          done()

    it 'does not update a person for invalid payload', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/person'
        payload:
          first_name: 'Bob'
          last_name: 'Jones'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'PUT'
          url: '/api/v1/person/' + p1.id
          payload:
            first_name: 'Only a first'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 400 # Bad request
          done()

    it 'does not update a person for invalid ID', (done) ->
      req =
        method: 'PUT'
        url: '/api/v1/person/NotAPerson'
        payload:
          first_name: 'First'
          last_name: 'Last'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad request
        done()

    it 'does not update a non-existent person', (done) ->
      req =
        method: 'PUT'
        url: '/api/v1/person/42'
        payload:
          first_name: 'First'
          last_name: 'Last'
      server.inject req, (res) ->
        res.statusCode.should.equal 404
        req2 =
          method: 'GET'
          url: '/api/v1/person/42'
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 404
          done()

  describe 'Delete', ->
    it 'deletes a person', (done) ->
      req1 =
        method: 'POST'
        url: '/api/v1/person'
        payload:
          first_name: 'Bob'
          last_name: 'Jones'
      server.inject req1, (res1) ->
        p1 = JSON.parse res1.payload
        req2 =
          method: 'DELETE'
          url: '/api/v1/person/' + p1.id
        server.inject req2, (res2) ->
          res2.statusCode.should.equal 204 # No Content
          res2.payload.should.be.empty()
          req3 =
            method: 'GET'
            url: '/api/v1/person'
          server.inject req3, (res3) ->
            res3.statusCode.should.equal 200
            JSON.parse(res3.payload).should.be.an.Array
            JSON.parse(res3.payload).should.be.empty()
            done()

    it 'returns an error when trying to delete an invalid person', (done) ->
      req =
        method: 'DELETE'
        url: '/api/v1/person/NotAPerson'
      server.inject req, (res) ->
        res.statusCode.should.equal 400 # Bad Request
        done()

    it 'returns an error when deleting a non-existent person', (done) ->
      req =
        method: 'DELETE'
        url: '/api/v1/person/1'
      server.inject req, (res) ->
        res.statusCode.should.equal 404 # Not Found
        done()
