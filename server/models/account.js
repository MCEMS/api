module.exports = function(Account) {
  Account.prototype.roles = function(done) {
    var Role = Account.app.models.Role;
    var RoleMapping = Account.app.models.RoleMapping;

    RoleMapping.find({
      where: {
        principalType: RoleMapping.USER,
        principalId: this.id
      },
      include: [
        'role'
      ]
    }, function(err, roleMappings) {
      if (err) {
        done(err);
      } else {
        if (roleMappings) {
          var roles = roleMappings.map(function(roleMapping) {
            return {
              id: roleMapping.role().id,
              name: roleMapping.role().name,
              description: roleMapping.role().description
            };
          });
          done(null, roles);
        } else {
          done(null, []);
        }
      }
    });
  };

  Account.remoteMethod('roles', {
    accepts: [],
    isStatic: false,
    returns: {
      arg: 'roles',
      root: true
    },
    http: {
      path: '/roles',
      verb: 'get',
      status: 200,
      errorStatus: 400
    }
  });

  Account.prototype.addRole = function(roleId, done) {
    var Role = Account.app.models.Role;
    var RoleMapping = Account.app.models.RoleMapping;
    var accountId = this.id;

    Role.exists(roleId, function(err, exists) {
      if (err) {
        done(err);
      } else if (exists) {
        RoleMapping.create({
          principalType: RoleMapping.USER,
          principalId: accountId,
          roleId: roleId
        }, done);
      } else {
        done(new Error('Role does not exist'));
      }
    });
  };

  Account.remoteMethod('addRole', {
    accepts: [
      {
        arg: 'roleId',
        type: 'number',
        required: true
      }
    ],
    isStatic: false,
    returns: {
      arg: 'roleMapping',
      root: true
    },
    http: {
      path: '/roles',
      verb: 'post',
      status: 201,
      errorStatus: 400
    }
  });

  Account.prototype.removeRole = function(roleId, done) {
    var RoleMapping = Account.app.models.RoleMapping;
    RoleMapping.destroyAll({
      principalType: RoleMapping.USER,
      principalId: this.id,
      roleId: roleId
    }, done);
  };

  Account.remoteMethod('removeRole', {
    accepts: [
      {
        arg: 'roleId',
        type: 'number',
        required: true,
        http: {
          source: 'path'
        }
      }
    ],
    isStatic: false,
    returns: {
      arg: 'info',
      root: true
    },
    http: {
      path: '/roles/:roleId',
      verb: 'delete',
      status: 204,
      errorStatus: 400
    }
  });

  Account.availableRoles = function(done) {
    var Role = Account.app.models.Role;
    Role.find({
      fields: [
        'id',
        'name',
        'description'
      ]
    }, done);
  };

  Account.remoteMethod('availableRoles', {
    accepts: [],
    isStatic: true,
    returns: {
      arg: 'roles',
      root: true
    },
    http: {
      path: '/roles',
      verb: 'get',
      status: 200,
      errorStatus: 400
    }
  });
};
