exports.up = function(knex, Promise) {
  return knex.schema.createTable('Client', function(table) {
    table.increments('id').primary();
    table.string('name').unique().notNullable();
    table.string('callback_url').notNullable();
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('Client');
};
