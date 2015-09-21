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

  it 'creates a person', (done) ->
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

  it 'deletes a person', (done) ->
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
        method: 'DELETE'
        url: '/api/v1/person/' + p1.id

      server.inject req2, (res2) ->
        res2.statusCode.should.equal 204
        res2.payload.should.be.empty()

        req3 =
          method: 'GET'
          url: '/api/v1/person'

        server.inject req3, (res3) ->
          res3.statusCode.should.equal 200
          JSON.parse(res3.payload).should.be.an.Array
          JSON.parse(res3.payload).should.be.empty()
          done()
