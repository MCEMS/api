module.exports = {
  docker: {
    client: 'postgresql',
    connection: {
      host: 'postgres',
      user: 'mcems',
      password: 'mcems',
      database: 'mcems'
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  travis: {
    client: 'postgresql',
    connection: {
      database: 'travis',
      user: 'postgres',
      password: ''
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: 'postgresql',
    connection: process.env.DATABASE_URL,
    migrations: {
      tableName: 'knex_migrations'
    }
  }
};

