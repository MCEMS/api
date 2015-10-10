Boom = require 'boom'
Joi = require 'joi'
Postmark = require 'postmark'
if process.env.NODE_ENV == 'production'
  client = new Postmark.Client process.env.POSTMARK_API_KEY
else
  client =
    sendEmail: (message, cb) ->
      console.log '----OUTBOUND EMAIL----\n' + message.TextBody + '\n----------------------'
      cb null,
        ErrorCode: 0,
        Message: 'OK',
        MessageID: '0',
        SubmittedAt: '2010-11-26T12:01:05.1794748-05:00',
        To: message.To?

getAlert = (opts) ->
  opts.address = '2400 CHEW ST' unless opts.address
  opts.city = 'ALLENTOWN' unless opts.city
  opts.info = 'Nothing further' unless opts.info
  message = 'CALL: ' + opts.type + '\n' +
    'PLACE: ' + opts.location + '\n' +
    'ADDR: ' + opts.address + '\n' +
    'CITY: ' + opts.city + '\n' +
    'INFO: ' + opts.info + '\n'
  message

sendAlert = (message, cb) ->
  client.sendEmail
    'From': 'noreply@bergems.org'
    'To': process.env.ACTIVE911_ALERT_EMAIL
    'TextBody': message
  , (err, result) ->
    if err
      console.error err
      cb err
    else
      cb null

module.exports.getAlert = getAlert
module.exports.sendAlert = sendAlert
module.exports.addRoutes = (server) ->
  server.route
    method: 'POST'
    path: '/api/v1/alert'
    config:
      auth:
        scope: [ 'send_alert' ]
      validate:
        payload:
          type: Joi.string().required()
          location: Joi.string().required()
          address: Joi.string()
          city: Joi.string()
          info: Joi.string()
    handler: (request, reply) ->
      sendAlert getAlert(request.payload), (err) ->
        if err
          reply Boom.badImplementation()
        else
          reply().code 204 # no content
