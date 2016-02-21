module.exports = function(server) {
  var tables = [
    'Account',
    'AccessToken',
    'ACL',
    'RoleMapping',
    'Role',
    'Person'
  ];
  server.dataSources.db.isActual(tables, function(err, actual) {
    if (!actual) {
      server.dataSources.db.autoupdate(tables, function(err, result) {
        if (err) {
          console.error('Error autoupdating data source:', err);
          throw err;
        } else {
          console.log('Autoupdate of data source is complete:', result);
        }
      });
    }
  });
};
