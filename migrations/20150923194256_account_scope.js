exports.up = function(knex, Promise) {
  return knex.schema.createTable('Account_Scope', function(table) {
    table.integer('account_id').notNullable().references('id').inTable('Account');
    table.integer('scope_id').notNullable().references('id').inTable('Scope');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('Account_Scope');
};
