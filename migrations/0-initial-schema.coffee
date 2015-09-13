module.exports =
  up: (migration, Types) ->
    migration.createTable 'Person',
      id:
        type: Types.INTEGER
        primaryKey: true
        autoIncrement: true
      first_name:
        type: Types.STRING
        allowNull: false
      last_name:
        type: Types.STRING
    
    migration.createTable 'Account',
      id:
        type: Types.INTEGER
        primaryKey: true
        autoIncrement: true
      username:
        type: Types.STRING
        allowNull: false
      password:
        type: Types.STRING
        allowNull: false
      login_enabled:
        type: Types.BOOLEAN
        defaultValue: true
    
    migration.createTable 'Usr',
      person_id:
        type: Types.INTEGER
        allowNull: false
      account_id:
        type: Types.INTEGER
        allowNull: false

    migration.createTable 'Scope',
      id:
        type: Types.INTEGER
        primaryKey: true
        autoIncrement: true
      key:
        type: Types.STRING

    migration.createTable 'Client',
      id:
        type: Types.INTEGER
        primaryKey: true
        autoIncrement: true
      name:
        type: Types.STRING
      description:
        type: Types.STRING
      bypass:
        type: Types.BOOLEAN
        defaultValue: false
      redirect_url:
        type: Types.STRING

    migration.createTable 'Client_Authorization',
      id:
        type: Types.INTEGER
        primaryKey: true
        autoIncrement: true
      client_id:
        type: Types.INTEGER
        allowNull: false
      account_id:
        type: Types.INTEGER
        allowNull: false

    migration.createTable 'Account_Scope',
      account_id:
        type: Types.INTEGER
        allowNull: false
      scope_id:
        type: Types.INTEGER
        allowNull: false

    migration.createTable 'Client_Authorization_Scope',
      client_authorization_id:
        type: Types.INTEGER
        allowNull: false
      scope_id:
        type: Types.INTEGER
        allowNull: false
    
  down: (migration, Types) ->
    migration.dropTable 'Usr'
    migration.dropTable 'Account'
    migration.dropTable 'Person'
    migration.dropTable 'Client'
    migration.dropTable 'Client_Authorization'
    migration.dropTable 'Account_Scope'
    migration.dropTable 'Scope'
    migration.dropTable 'Client_Authorization_Scope'

