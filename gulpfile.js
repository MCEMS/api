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

gulp.task('test', function() {
  return gulp.src('./tests/*.coffee')
    .pipe(mocha());
});

gulp.task('default', [ 'lint', 'test' ]);
