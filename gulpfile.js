// npm i --save-dev gulp gulp-sass gulp-autoprefixer gulp-minify-css gulp-uglify gulp-imagemin gulp-rename gulp-concat gulp-cache del

// Load plugins
var gulp = require('gulp'),
sass = require('gulp-sass'),
autoprefixer = require('gulp-autoprefixer'),
minifycss = require('gulp-minify-css'),
uglify = require('gulp-uglify'),
imagemin = require('gulp-imagemin'),
rename = require('gulp-rename'),
concat = require('gulp-concat'),
cache = require('gulp-cache'),
del = require('del')

var paths = {
  // SCSS Files
  scss: 'src/stylesheets/main.scss',
};

// Styles
gulp.task('styles', function() {
  return gulp.src(paths.scss)
    .pipe(sass())
    .pipe(autoprefixer('last 2 version'))
    .pipe(minifycss())
    .pipe(concat('application.css'))
    .pipe(gulp.dest('app/assets/stylesheets'));
  }
);

// Images
gulp.task('images', function() {
  return gulp.src('src/images/**/*')
    .pipe(cache(imagemin({ optimizationLevel: 3, progressive: true, interlaced: true })))
    .pipe(gulp.dest('app/assets/images'));
});

// Clean
gulp.task('clean', function() {
  return del(['app/assets/stylesheets', 'app/assets/images']);
});

// Default task
gulp.task('default', ['clean'], function() {
  gulp.start('styles', 'images', 'watch');
});

// Watch
gulp.task('watch', function() {

  // Watch .scss files
  gulp.watch('src/stylesheets/**/*.scss', ['styles']);

  // Watch image files
  gulp.watch('src/images/**/*', ['images']);

});