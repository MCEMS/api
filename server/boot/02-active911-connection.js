var Active911 = require('active911');
var Redis = require('redis');

var REDIS_ALERTS_KEY = 'active911:alerts';
var redisKeyForAlert = function(id) {
  return 'active911:alert:' + id;
};
var redisKeyForDevice = function(id) {
  return 'active911:device_name:' + id;
};
var REDIS_ALERTS_EXPIRATION = 30;
var REDIS_ALERT_EXPIRATION = 30;
var REDIS_DEVICE_EXPIRATION = 60 * 60 * 24;

module.exports = function(server) {
  server.set('active911',
    new Active911.RefreshClient(process.env.ACTIVE911_REFRESH_TOKEN)
  );
  server.set('redis', Redis.createClient(process.env.REDIS_URL));

  var active911 = server.get('active911');
  var redis = server.get('redis');

  var getCachedAlerts = function() {
    return new Promise(function(fulfill, reject) {
      redis.exists(REDIS_ALERTS_KEY, function(err, exists) {
        if (exists === 1) {
          redis.smembers(REDIS_ALERTS_KEY, function(err, cachedAlerts) {
            if (err) {
              reject(err);
            } else {
              console.log('using cached alert IDs');
              fulfill(cachedAlerts);
            }
          });
        } else {
          active911.getAlerts({ 'alert_days': 2 }).then(function(realAlerts) {
            realAlerts.map(function(alert) {
              console.log('adding alert id to cache:', alert.id);
              redis.sadd(REDIS_ALERTS_KEY, alert.id);
            });
            redis.expire(REDIS_ALERTS_KEY, REDIS_ALERTS_EXPIRATION);
            fulfill(realAlerts.map(function(alert) {
              return alert.id;
            }));
          }).catch(function(err) {
            reject(err);
          });
        }
      });
    });
  };

  var getCachedAlert = function(id) {
    return new Promise(function(fulfill, reject) {
      redis.get(redisKeyForAlert(id), function(err, cachedAlert) {
        if (err) {
          reject(err);
        } else {
          if (cachedAlert) {
            console.log('using cached alert');
            fulfill(JSON.parse(cachedAlert));
          } else {
            active911.getAlert(id).then(function(realAlert) {
              redis.set(redisKeyForAlert(id), JSON.stringify(realAlert));
              redis.expire(redisKeyForAlert(id), REDIS_ALERT_EXPIRATION);
              console.log('caching alert', redisKeyForAlert(id));
              fulfill(realAlert);
            }).catch(function(err) {
              reject(err);
            });
          }
        }
      });
    });
  };

  var getCachedDeviceName = function(id) {
    return new Promise(function(fulfill, reject) {
      redis.get(redisKeyForDevice(id), function(err, cachedDeviceName) {
        if (err) {
          reject(err);
        } else {
          if (cachedDeviceName) {
            console.log('using cached device name', cachedDeviceName);
            fulfill(cachedDeviceName);
          } else {
            active911.getDevice(id).then(function(realDevice) {
              redis.set(redisKeyForDevice(id), realDevice.name);
              redis.expire(redisKeyForDevice(id), REDIS_DEVICE_EXPIRATION);
              console.log('caching device name', redisKeyForDevice(id));
              fulfill(realDevice.name);
            }).catch(function(err) {
              reject(err);
            });
          }
        }
      });
    });
  };

  var getResponseForReply = function(rawResponse) {
    return new Promise(function(fulfill, reject) {
      getCachedDeviceName(rawResponse.device.id).then(function(name) {
        fulfill({
          name: name,
          deviceId: rawResponse.device.id,
          response: rawResponse.response,
          timestamp: rawResponse.timestamp
        });
      }).catch(function(err) {
        reject(err);
      });
    });
  };

  var getAlertForReply = function(rawAlert) {
    return new Promise(function(fulfill, reject) {
      var responses = rawAlert.responses.map(function(response) {
        return getResponseForReply(response);
      });
      Promise.all(responses).then(function(responses) {
        fulfill({
          id: rawAlert.id,
          description: rawAlert.description,
          details: rawAlert.details,
          place: rawAlert.place,
          address: rawAlert.place,
          timestamp: rawAlert.received,
          responses: responses
        });
      }).catch(function(err) {
        reject(err);
      });
    });
  };

  var getAlertsForReply = function() {
    return new Promise(function(fulfill, reject) {
      getCachedAlerts().then(function(ids) {
        var alertPromises = ids.map(function(id) {
          return getCachedAlert(id);
        });
        Promise.all(alertPromises).then(function(alerts) {
          var alertsForReply = alerts.map(function(alert) {
            return getAlertForReply(alert);
          });
          Promise.all(alertsForReply).then(function(alerts) {
            fulfill(alerts);
          }).catch(function(err) {
            reject(err);
          });
        }).catch(function(err) {
          reject(err);
        });
      }).catch(function(err) {
        reject(err);
      });
    });
  };

  server.set('getActive911Alerts', getAlertsForReply);
};
