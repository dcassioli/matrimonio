'use strict';
const gulp = require('gulp');
const path = require('path');
const ghPages = require('gh-pages');

// 'gulp deploy' -- pushes your dist folder to Github
gulp.task('upload', (done) => {
  ghPages.publish(path.join(__dirname + '/../../', 'dist'), {
    dotfiles: true,
    repo: 'git@github.com:dcassioli/matrimonio.git'
    // branch: "master"
	},
	done);
});
