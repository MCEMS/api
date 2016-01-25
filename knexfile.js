module.exports = {
  docker: {
    client: 'postgresql',
    connection: {
      host: 'postgres',
      user: 'mcems',
      password: 'mcems',
      database: 'mcems'
    },
    pool: {
      min: 1,
      max: 5
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
    pool: {
      min: 1,
      max: 5
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: 'postgresql',
    connection: process.env.DATABASE_URL,
    pool: {
      min: 1,
      max: 5
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }
};

