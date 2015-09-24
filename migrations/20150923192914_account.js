exports.up = function(knex, Promise) {
  return knex.schema.createTable('Account', function(table) {
    table.increments('id').primary();
    table.string('username').notNullable().unique();
    table.string('password');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('Account');
};
