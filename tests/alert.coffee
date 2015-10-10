require 'coffee-script'

should = require 'should'
utils = require './utils'
Alert = utils.Alert
server = utils.server

describe 'Alert', ->

  describe '#getAlert', ->
    it 'returns a message of the proper format', ->
      expected = 'CALL: aaa\nPLACE: bbb\nADDR: ccc\nCITY: ddd\nINFO: eee\n'
      actual = Alert.getAlert
        type: 'aaa'
        location: 'bbb'
        address: 'ccc'
        city: 'ddd'
        info: 'eee'
      actual.should.equal expected

  describe 'POST /alert', ->
    it 'sends an alert', (done) ->
      request =
        method: 'POST'
        url: '/api/v1/alert'
        credentials: utils.credentials
        payload:
          type: 'aaa'
          location: 'bbb'
      server.inject request, (response) ->
        response.statusCode.should.equal 204
        done()

    it 'requires credentials', (done) ->
      request =
        method: 'POST'
        url: '/api/v1/alert'
        payload:
          type: 'aaa'
          location: 'bbb'
      server.inject request, (response) ->
        response.statusCode.should.equal 401
        done()
