'use strict';

var Gulp = require('gulp');
var GIK  = require('gik');

for (let i in GIK) Gulp.task.apply(Gulp, GIK[i]);