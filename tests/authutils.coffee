require 'coffee-script'

should = require 'should'
AuthUtils = require '../lib/auth/utils'
decode = require 'jwt-decode'
SHA1 = require 'sha-1'

# Mock the Account object
mock_account_1 =
  id: 123
  related: (id) ->
    unless id isnt 'scopes'
      [
        {
          get: (id) ->
            unless id isnt 'key'
              'admin'
        }
      ]

# Mock a request
mock_request_1 =
  headers:
    'Accept-Language': 'en_US'
    'User-Agent': 'Firefox'
mock_request_2 =
  headers:
    'Accept-Language': 'en_US'
    'User-Agent': 'FireOx'

describe 'Auth Utils', ->
  describe 'Request Fingerprint', ->
    it 'generates a fingerprint for null headers', ->
      request =
        headers:
          'Random': 'value'
      AuthUtils.fingerprint(request).should.equal 'da39a3e'

    it 'generates a fingerprint for language header', ->
      request =
        headers:
          'Accept-Language': 'en_US'
      AuthUtils.fingerprint(request).should.equal 'fa73905'

    it 'generates a fingerprint for the UA header', ->
      request =
        headers:
          'User-Agent': 'Firefox'
      AuthUtils.fingerprint(request).should.equal 'b4ee652'

    it 'generates a fingerprint for both language and UA headers', ->
      request =
        headers:
          'User-Agent': 'Firefox'
          'Accept-Language': 'en_US'
      AuthUtils.fingerprint(request).should.equal 'f95a322'

  describe 'Token Generation', ->
    it 'generates a raw token', ->
      t0 = AuthUtils._generateTokenRaw 1, [ 'scope0' ], 'fingerprint'
      t1 = decode t0
      t1.should.have.keys 'exp', 'f', 'iat', 'scope', 'sub'
      t1.sub.should.equal 1
      t1.scope.should.be.an.Array
      t1.scope.length.should.equal 1
      t1.scope[0].should.equal 'scope0'
      t1.f.should.equal 'fingerprint'

    it 'generates token from account and request', ->
      t0 = AuthUtils.generateToken mock_account_1, mock_request_1
      t0.should.have.keys 'token', 'scope', 'expiresInSeconds'
      t0.scope.should.be.an.Array
      t0.scope.length.should.equal 1
      t0.scope[0].should.equal 'admin'
      t0.expiresInSeconds.should.equal AuthUtils.JWS_TTL
      t1 = decode t0.token
      t1.should.have.keys 'exp', 'f', 'iat', 'scope', 'sub'
      t1.sub.should.equal 123
      t1.scope.should.be.an.Array
      t1.scope.length.should.equal 1
      t1.scope[0].should.equal 'admin'
      t1.exp.should.equal t1.iat + AuthUtils.JWS_TTL
      t1.f.should.equal SHA1(
        mock_request_1.headers['User-Agent'] + mock_request_1.headers['Accept-Language']
      ).substr(0, 7)

  describe 'Token Validation', ->
    it 'validates good token', (done) ->
      t0 = AuthUtils.generateToken mock_account_1, mock_request_1
      t1 = decode(t0.token)
      AuthUtils.validateToken mock_request_1, t1, (err, success, credentials) ->
        should(err).equal null
        success.should.equal true
        credentials.should.have.keys 'id', 'scope'
        credentials.scope.should.be.an.Array
        credentials.scope.length.should.equal 1
        credentials.scope[0].should.equal t0.scope[0]
        done()

    it 'does not validate token with bad fingerprint', (done) ->
      t0 = AuthUtils.generateToken mock_account_1, mock_request_1
      t1 = decode(t0.token)
      AuthUtils.validateToken mock_request_2, t1, (err, success, credentials) ->
        err.should.equal true
        success.should.equal false
        should(credentials).equal null
        done()
