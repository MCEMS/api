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

