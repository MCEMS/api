module.exports = {

  development: {
    client: 'postgresql',
    connection: {
      database: 'mcems_development',
      user: 'postgres',
      password: 'postgres'
    },
    pool: {
      min: 2,
      max: 15
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  test: {
    client: 'postgresql',
    connection: {
      database: 'mcems_test',
      user: 'postgres',
      password: 'postgres'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  travis: {
    client: 'postgresql',
    connection: process.env.DATABASE_URL,
    pool: {
      min: 2,
      max: 15
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: 'postgresql',
    connection: process.env.DATABASE_URL,
    pool: {
      min: 2,
      max: 15
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }
};

