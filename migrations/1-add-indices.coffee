module.exports =
  up: (migration, Types) ->
    migration.addIndex 'Account', [ 'username' ],
      indicesType: 'UNIQUE'
    
    migration.addIndex 'Usr', [ 'person_id' ],
      indicesType: 'UNIQUE'
    
    migration.addIndex 'Usr', [ 'account_id' ],
      indicesType: 'UNIQUE'

    migration.addIndex 'Scope', [ 'key' ],
      indicesType: 'UNIQUE'

    migration.addIndex 'Client_Authorization', [ 'client_id', 'account_id' ],
      indicesType: 'UNIQUE'

    migration.addIndex 'Account_Scope', [ 'account_id', 'scope_id' ],
      indicesType: 'UNIQUE'

    migration.addIndex 'Client_Authorization_Scope', [ 'client_authorization_id', 'scope_id' ],
      indicesType: 'UNIQUE'

  down: (migration, Types) ->
    migration.removeIndex 'Usr', [ 'person_id' ]
    migration.removeIndex 'Usr', [ 'account_id' ]
    migration.removeIndex 'Account', [ 'username' ]
    migration.removeIndex 'Scope', [ 'key' ]
    migration.removeIndex 'Client_Authorization', [ 'client_id', 'account_id' ]
    migration.removeIndex 'Account_Scope', [ 'account_id', 'scope_id' ]
    migration.removeIndex 'Client_Authorization_Scope', [ 'client_authorization_id', 'scope_id' ]

