require 'coffee-script'

Joi = require 'joi'
Bcrypt = require 'bcrypt'
JWT = require 'jsonwebtoken'
Boom = require 'boom'
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

# Returns an object containing the generated token and
# the number of seconds it expires in.
generateToken = (account, request) ->
  scopes = []
  account.related('scopes').forEach (scope) ->
    scopes.push scope.get('key')
  token = JWT.sign
    scope: scopes
    f: fingerprint(request)
  , JWS_SECRET,
    expiresInSeconds: JWS_TTL
    subject: account.id

  return {
    token: token
    expiresInSeconds: JWS_TTL
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

module.exports = (server) ->
  Account = server.plugins['bookshelf']['Account']

  server.register require('hapi-auth-jwt'), (err) ->
    console.error err if err
    server.auth.strategy 'token', 'jwt', 'required',
      key: JWS_SECRET
      validateFunc: validateToken

  server.route
    method: 'POST'
    path: '/auth/key'
    config:
      auth: false
      validate:
        payload:
          username: Joi.string().required()
          password: Joi.string().required()
    handler: (request, reply) ->
      new Account
        username: request.payload.username
      .fetch
        withRelated: ['scopes']
      .then (acc) ->
        if acc
          Bcrypt.compare request.payload.password, acc.get('password'), (err, valid) ->
            if err
              reply Boom.badImplementation()
              console.error err
            else
              if valid
                reply generateToken(acc, request)
              else
                reply Boom.unauthorized()
        else
          reply Boom.unauthorized()
      .catch (err) ->
        reply Boom.badImplementation()
        console.error err
