require('coffee-script').register();
var gulp = require('gulp');
var coffeelint = require('gulp-coffeelint');
var mocha = require('gulp-mocha');

gulp.task('lint', function() {
  return gulp.src('./lib/**/*.coffee')
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(coffeelint.reporter('fail'));
});

gulp.task('test', [ 'migrate' ], function() {
  return gulp.src('./tests/*.coffee')
    .pipe(mocha())
    .once('end', function() {
      process.exit(0);
    })
    .once('error', function() {
      process.exit(1);
    });
});

gulp.task('migrate', function() {
  var env = process.env.NODE_ENV || 'development';
  var config = require('./knexfile')[env];
  var knex = require('knex')(config);
  return knex.migrate.latest().then(function() {
    return knex.destroy();
  });
});

gulp.task('seed', [ 'migrate' ], function() {
  var env = process.env.NODE_ENV || 'development';
  var config = require('./knexfile')[env];
  var knex = require('knex')(config);
  return knex.seed.run().then(function() {
    return knex.destroy();
  });
});

gulp.task('default', [ 'lint', 'test' ], function() {
  process.exit(0);
});
