Boom = require 'boom'
Joi = require 'joi'

REDIS_ALERTS_KEY = 'active911:alerts'
redisKeyForAlert = (id) -> 'active911:alert:' + id
redisKeyForDevice = (id) -> 'active911:device_name:' + id
REDIS_ALERTS_EXPIRATION = 30 # seconds
REDIS_ALERT_EXPIRATION = 30 # seconds
REDIS_DEVICE_EXPIRATION = 60 * 60 * 24 # one day

module.exports = (server) ->

  active911 = server.plugins.active911.active911
  redis = server.plugins.redis.redis

  getCachedAlerts = ->
    return new Promise (fulfill, reject) ->
      redis.exists REDIS_ALERTS_KEY, (err, exists) ->
        if exists == 1
          redis.smembers REDIS_ALERTS_KEY, (err, cachedAlerts) ->
            reject(err) if err
            fulfill(cachedAlerts)
        else
          active911.getAlerts().then (realAlerts) ->
            realAlerts.map (alert) -> redis.sadd(REDIS_ALERTS_KEY, alert.id)
            redis.expire(REDIS_ALERTS_KEY, REDIS_ALERTS_EXPIRATION)
            fulfill(realAlerts.map (alert) -> alert.id)
          .catch (err) ->
            reject(err)

  getCachedAlert = (id) ->
    return new Promise (fulfill, reject) ->
      redis.get redisKeyForAlert(id), (err, cachedAlert) ->
        reject(err) if err
        if cachedAlert
          fulfill(JSON.parse(cachedAlert))
        else
          active911.getAlert(id).then (realAlert) ->
            redis.set(redisKeyForAlert(id), JSON.stringify(realAlert))
            redis.expire(redisKeyForAlert(id), REDIS_ALERT_EXPIRATION)
            fulfill(realAlert)
          .catch (err) ->
            reject(err)

  getCachedDeviceName = (id) ->
    return new Promise (fulfill, reject) ->
      redis.get redisKeyForDevice(id), (err, cachedDeviceName) ->
        reject(err) if err
        if cachedDeviceName
          fulfill(cachedDeviceName)
        else
          active911.getDevice(id).then (realDevice) ->
            redis.set(redisKeyForDevice(id), realDevice.name)
            redis.expire(redisKeyForDevice, REDIS_DEVICE_EXPIRATION)
            fulfill(realDevice.name)
          .catch (err) ->
            reject(err)

  getResponseForReply = (rawResponse) ->
    return new Promise (fulfill, reject) ->
      getCachedDeviceName(rawResponse.device.id).then (name) ->
        response =
            name: name
            deviceId: rawResponse.device.id
            response: rawResponse.response
            timestamp: rawResponse.timestamp
        fulfill response
      .catch (err) ->
        reject err

  getAlertForReply = (rawAlert) ->
    return new Promise (fulfill, reject) ->
      responses = rawAlert.responses.map (response) -> getResponseForReply(response)
      Promise.all(responses).then (responses) ->
        alert =
          id: rawAlert.id
          description: rawAlert.description
          details: rawAlert.details
          place: rawAlert.place
          address: rawAlert.address
          timestamp: rawAlert.received
          responses: responses
        fulfill alert
      .catch (err) ->
        reject err

  getAlertsForReply = ->
    return new Promise (fulfill, reject) ->
      getCachedAlerts().then (ids) ->
        alertPromises = ids.map (id) -> getCachedAlert(id)
        Promise.all(alertPromises).then (alerts) ->
          alertsForReply = alerts.map (alert) -> getAlertForReply(alert)
          Promise.all(alertsForReply).then (alerts) ->
            fulfill alerts
          .catch (err) ->
            reject err
        .catch (err) ->
          reject err
      .catch (err) ->
        reject err

  server.route
    method: 'GET'
    path: '/api/v1/active911/alert'
    config:
      auth:
        scope: [ 'admin', 'send_alert' ]
    handler: (request, reply) ->
      getAlertsForReply().then (alerts) ->
        reply alerts
      .catch (err) ->
        console.error err
        reply Boom.badImplementation()
