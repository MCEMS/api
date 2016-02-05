var server = require('../server/server');
var Account = server.models.Account;
var Role = server.models.Role;
var RoleMapping = server.models.RoleMapping;

Account.create({
  username: 'admin',
  password: 'admin',
  email: 'admin@bergems.org'
}, function(err, account) {
  if (err) {
    console.error('Error creating account:', err);
  } else {
    Role.findOne({ where: { name: 'admin' }}, function(err, role) {
      role.principals.create({
        principalType: RoleMapping.USER,
        principalId: account.id
      }, function(err, principal) {
        if (err) {
          console.error('Error creating principal:', err);
        } else {
          console.log('Successfully created account and assigned to role');
        }
      });
    });
  }
});
