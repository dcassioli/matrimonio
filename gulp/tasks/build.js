'use strict';
const gulp = require('gulp');
const shell = require('shelljs');
const size = require('gulp-size');
const argv = require('yargs').argv;

// 'gulp jekyll:tmp' -- copies your Jekyll site to a temporary directory
// to be processed
gulp.task('site:tmp', () =>
  gulp.src(['src/**/*', '!src/images/**/*', '!src/images', 
            '!src/javascript/**/*', '!src/javascript', 
            '!src/scss/**/*', '!src/scss', 
            'src/favicon.ico'], {dot: true})
    .pipe(gulp.dest('.tmp/src'))
    .pipe(size({title: 'Jekyll'}))
);

// 'gulp jekyll' -- builds your site with development settings
// 'gulp jekyll --prod' -- builds your site with production settings
gulp.task('site', done => {
  shell.exec('bundle update');
  if (!argv.prod) {
    shell.exec('bundle exec jekyll build');
    done();
  } else if (argv.prod) {
    shell.exec('bundle exec jekyll build --config _config.yml,_config.build.yml');
    done();
  }
});

// 'gulp doctor' -- literally just runs jekyll doctor
gulp.task('site:check', done => {
  shell.exec('jekyll doctor');
  done();
});
