require 'coffee-script'

JWT = require 'jsonwebtoken'
SHA1 = require 'sha-1'

JWS_SECRET = process.env.TOKEN_SIGNING_SECRET or '123456'
JWS_TTL = 1800

# Rudimentary browser fingerprinting to counter session hijacking
#
# This will allow us to make sure the browser making the request is the same
# browser that the token was issued to by hashing some headers and storing them
# in the signed token.
#
# When a request is made, we can recalculate the fingerprint and compare it to
# the one stored in the token.
#
# Since a long fingerprint will make the bearer token longer, we'll just grab
# the first 7 chars of the SHA hash.
fingerprint = (request) ->
  ua = request.headers['User-Agent'] or request.headers['user-agent'] or ''
  lang = request.headers['Accept-Language'] or request.headers['accept-language'] or ''
  sha = SHA1(ua + lang)
  sha.substr 0, 7

# Generates a token containing the specified subject, scopes, and browser
# fingerprint.
#
# This method should never be called externally, but is exposed for testing.
_generateTokenRaw = (subject, scopes, fp) ->
  JWT.sign
    scope: scopes
    f: fp
  , JWS_SECRET,
    expiresInSeconds: JWS_TTL
    subject: subject

# Returns an object containing the generated token and
# the number of seconds it expires in.
generateToken = (account, request) ->
  scopes = []
  account.related('scopes').forEach (scope) ->
    scopes.push scope.get('key')
  fp = fingerprint request
  token = _generateTokenRaw account.id, scopes, fp
  return {
    token: token
    expiresInSeconds: JWS_TTL
    scope: scopes
  }

# Used by hapi-auth-jwt to validate a token.
#
# All that we need to do is pick out the credentials from the token;
# we're not doing any validation on the account to avoid slow DB calls.
validateToken = (request, token, cb) ->
  err = null
  credentials = null
  success = false
  if fingerprint(request) == token.f
    success = true
    credentials =
      id: token.subject
      scope: token.scope
  else
    err = true
  cb err, success, credentials

module.exports.JWS_SECRET = JWS_SECRET
module.exports.JWS_TTL = JWS_TTL
module.exports.fingerprint = fingerprint
module.exports._generateTokenRaw = _generateTokenRaw
module.exports.generateToken = generateToken
module.exports.validateToken = validateToken
