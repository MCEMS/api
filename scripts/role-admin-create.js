var server = require('../server/server');

server.models.Role.create({
  name: 'admin',
  description: 'Administrative access'
}, function(err, role) {
  if (err) {
    console.error('Error creating role:', err);
  } else {
    console.log('Admin role created');
  }
});
