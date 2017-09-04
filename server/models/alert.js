var sendgridClientStub = {
  setApiKey: function(key) {
    // stub -- do nothing
  },
  send: function(msg) {
    return new Promise(function(resolve, reject) {
      console.log('-----SENDGRID API-----');
      console.log(JSON.stringify(msg));
      console.log('-----END SENDGRID API-----');
      resolve();
    });
  },
};

var sg = (
  (process.env.NODE_ENV === 'production') ?
  require('@sendgrid/mail') : sendgridClientStub
);
sg.setApiKey(process.env.SENDGRID_API_KEY);

// Convert an object into a string message for email sending
// options.location and options.type are required -- all others are optional
var getAlert = function(alert) {
  if (!alert.address) {
    alert.address = '2400 W CHEW ST';
  }
  if (!alert.city) {
    alert.city = 'ALLENTOWN';
  }
  if (!alert.info) {
    alert.info = 'Nothing further';
  }

  var message = 'CALL: ' + alert.type + '\n' +
    'PLACE: ' + alert.location + '\n' +
    'ADDR: ' + alert.address + '\n' +
    'CITY: ' + alert.city + '\n' +
    'INFO: ' + alert.info + '\n';

  return message;
};

module.exports = function(Alert) {

  Alert.fetchRecent = function(done) {
    var getActive911Alerts = Alert.app.get('getActive911Alerts');
    getActive911Alerts().then(function(alerts) {
      done(null, alerts);
    }).catch(function(err) {
      done(err);
    });
  };

  Alert.remoteMethod('fetchRecent', {
    accepts: [],
    description: 'Get recent alerts',
    returns: {
      type: 'array',
      root: true
    },
    http: {
      path: '/fetchRecent',
      verb: 'GET',
      status: 200,
      errorStatus: 400
    }
  });

  Alert.send = function(alert, done) {
    if (
      alert === undefined ||
      alert.type === undefined ||
      alert.location === undefined
    ) {
      done(new Error('Alert type and location must be specified'));
    } else {
      var msg = {
        to: process.env.ACTIVE911_ALERT_EMAIL,
        from: 'noreply@bergems.org',
        subject: '',
        text: getAlert(alert),
      };
      sg.send(msg).then(function() {
        console.log('Message sent!');
        done();
      }).catch(function(err) {
        console.error('Error sending message', err);
        done(err.toString());
      });
    }
  };

  Alert.remoteMethod('send', {
    accepts: [
      {
        arg: 'alert',
        description: 'The alert to generate',
        http: {
          source: 'body'
        },
        required: true,
        type: 'object'
      }
    ],
    description: 'Send an alert through the Active911 API',
    http: {
      path: '/send',
      verb: 'POST',
      status: 201,
      errorStatus: 400
    }
  });
};
