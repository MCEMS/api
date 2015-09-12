require 'coffee-script'

should = require 'should'
server = require '../lib/server.coffee'

describe 'Server', ->
  it 'should return 404 for root path', (done) ->
    request =
      method: 'GET'
      url: '/'

    server.inject request, (response) ->
      response.statusCode.should.equal 404
      done()



