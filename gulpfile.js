require('coffee-script').register();
var gulp = require('gulp');
var coffeelint = require('gulp-coffeelint');
var mocha = require('gulp-mocha');
var knex = require('knex');

gulp.task('lint', function() {
  gulp.src('./lib/**/*.coffee')
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(coffeelint.reporter('fail'));
});

gulp.task('test', function() {
  gulp.src('./tests/*.coffee', { read: false })
    .pipe(mocha({ reporter: 'list' }));
});

gulp.task('default', [ 'lint', 'test' ]);

