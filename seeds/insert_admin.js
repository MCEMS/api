var USERNAME = 'admin';
// password is "admin"
var PASSWORD = '$2a$12$IRUA2Rx49RDm9MeQqfwTRuyTvfqrf9.P.kaE.1tDYHAgZIe1G6vvu';
var scope = { key: 'admin', description: 'Grant administrative API access' };
var account = { username: USERNAME, password: PASSWORD };
var account_scope = { account_id: 1, scope_id: 1 };

exports.seed = function(knex, Promise) {
  return knex.insert(scope).into('Scope').then(function() {
    return knex.insert(account).into('Account');
  }).then(function() {
    return knex.insert(account_scope).into('Account_Scope');
  });
};