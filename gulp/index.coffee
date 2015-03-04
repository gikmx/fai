'use strict'

Gulp   = require 'gulp'
Util   = require 'gulp-util'
Clean  = require 'gulp-clean'
Coffee = require 'gulp-coffee'

Gulp.task 'clean', ->
	Gulp.src './lib', read:false
		.pipe do Clean


Gulp.task 'build', ['clean'], ->

	Gulp.src ['!./src/**/*.coffee','./src/**/*.*']
		.pipe Gulp.dest './lib'

	Gulp.src ['./src/**/*.coffee']
		.pipe Coffee bare:true
			.on 'error', Util.log
		.pipe Gulp.dest './lib'

