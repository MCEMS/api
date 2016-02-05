var server = require('../server/server');

server.models.Role.create({
  name: 'dispatch',
  description: 'Access to send and read alerts'
}, function(err, role) {
  if (err) {
    console.error('Error creating role:', err);
  } else {
    console.log('Dispatch role created');
  }
});
