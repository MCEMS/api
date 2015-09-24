exports.up = function(knex, Promise) {
  return knex.schema.createTable('Scope', function(table) {
    table.increments('id').primary();
    table.string('key').notNullable().unique();
    table.string('description').notNullable();
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('Scope');
};
