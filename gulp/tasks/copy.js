'use strict';
const gulp = require('gulp');

// 'gulp assets:copy' -- copies the assets into the dist directory, needs to be
// done this way because Jekyll overwrites the whole directory otherwise
gulp.task('copy:assets', () =>
  gulp.src('.tmp/assets/**/*')
    .pipe(gulp.dest('dist/assets'))
);

// 'gulp copy:css' -- copies plain css files into the already compiled stylesheets
// directory to make them available on the output site.
// Must be executed before the copy:assets task
gulp.task('copy:css', () =>
  gulp.src('src/scss/*.css')
    .pipe(gulp.dest('.tmp/assets/stylesheets'))
);

// 'gulp jekyll:copy' -- copies your processed Jekyll site to the dist directory
gulp.task('copy:site', () =>
  gulp.src('.tmp/dist/**/*')
    .pipe(gulp.dest('dist'))
);

