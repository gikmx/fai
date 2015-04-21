'use strict';

var Gulp   = require('gulp');
var Util   = require('gulp-util');
var Coffee = require('gulp-coffee');
var Del    = require('del');
var Pipe   = require('lazypipe');

var path = {
	src: './src',
	lib: './lib'
};

var filesAll    = path.src + "/**/*.*";
var filesCoffee = path.src + "/**/*.coffee";
var filesOthers = "!" + filesCoffee;

var pipeDest   = Pipe().pipe(Gulp.dest, path.lib);
var pipeCoffee = Pipe().pipe(Coffee, {bare: true}).pipe(Gulp.dest, path.lib);

Gulp.task('clean', function() {
	return Del.sync(['./lib'], { force: true });
});

Gulp.task('misc', function() {
	return Gulp.src([filesOthers, filesAll]).pipe(pipeDest());
});

Gulp.task('build', ['clean', 'misc'], function() {
	return Gulp.src([filesCoffee]).pipe(pipeCoffee());
});
