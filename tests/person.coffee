require 'coffee-script'

should = require 'should'
server = require '../lib/server.coffee'

describe 'Person', ->
  it 'returns a list of people', (done) ->
    request =
      method: 'GET'
      url: '/api/v1/person'

    server.inject request, (response) ->
      response.statusCode.should.equal 200
      response.payload.should.not.be.empty()
      response.payload.should.equal 'ASDASD'
      done()



