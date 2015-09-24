exports.up = function(knex, Promise) {
  return knex.schema.createTable('APIUser', function(table) {
    table.integer('person_id').notNullable().unique().references('id').inTable('Person');
    table.integer('account_id').notNullable().unique().references('id').inTable('Account');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('APIUser');
};
