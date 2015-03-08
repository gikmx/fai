'use strict'

Gulp   = require 'gulp'
Util   = require 'gulp-util'
Coffee = require 'gulp-coffee'
Watch  = require 'gulp-watch'

Del    = require 'del'
Pipe   = require 'lazypipe'

path =
	src:'./src'
	lib:'./lib'

filesAll    = "#{path.src}/**/*.*"
filesCoffee = "#{path.src}/**/*.coffee"
filesOthers = "!#{filesCoffee}"

pipeDest    = Pipe().pipe(Gulp.dest, path.lib)
pipeCoffee  = Pipe().pipe(Coffee, bare:true).pipe(Gulp.dest, path.lib)

Gulp.task 'clean', ->
	Del.sync ['./lib'], force:true

Gulp.task 'misc' , ->
	Gulp.src([filesOthers, filesAll]).pipe do pipeDest

Gulp.task 'build', ['clean','misc'], ->
	Gulp.src([filesCoffee]).pipe do pipeCoffee

Gulp.task 'watch', ['build'], ->
	Gulp.src([filesCoffee]).pipe(Watch filesCoffee).pipe do pipeCoffee
