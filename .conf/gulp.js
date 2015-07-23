'use strict';

//--------------------------------------------------------------------------- NODE MODULES

const Path = require('path');

//---------------------------------------------------------------------------- NPM MODULES

const Gulp   = require('gulp');
const Lint   = require('gulp-eslint');
const Source = require('gulp-sourcemaps');
const SrcSup = require('gulp-sourcemaps-support');
const Babel  = require('gulp-babel');
const Mocha  = require('gulp-spawn-mocha');
const Watch  = require('gulp-watch');
const Docs   = require('gulp-fai-doc');
const Del    = require('del');
const Chalk  = require('chalk');

//------------------------------------------------------------------------- PATHS & ROUTES

const Dir = new String(Path.resolve(Path.join(__dirname, '..')));

for (let dir of ['src', 'test', 'docs', 'build', '.conf', 'coverage'])
	Object.defineProperty(Dir, dir, {
		value        : Path.join(String(Dir), dir),
		writable     : false,
		enumerable   : true,
		configurable : false
	});

const Route = {
	src   : [Path.join(Dir.src, '/**/*.js')],
	test  : [Path.join(Dir.test, '/**/*.js')],
	index : Path.resolve(Dir.build, 'index.js')
};


//-------------------------------------------------------------------------- CONFIGURATION

const Config = {};

Config.lint = {

	src: {
		useEslintrc : true
	},

	test: {
		rulesPath   : [Dir.test],
		useEslintrc : true
	}
};

Config.babel = {
	optional      : ['runtime'],
	sourceMap     : ['both'],
	blacklist     : ['strict'], // removes use strict
	stage         : 1,
	sourceMapName : '.map',
	sourceRoot    : Dir.src,
	comments      : false
};

Config.mocha = {
	ui        : 'bdd',
	bail      : true,
	require   : Path.join(Dir['.conf'], 'chai'),
	reporter  : 'mocha-unfunk-reporter',
	compilers : 'js:babel/register',
	istanbul  : process.env.NODE_ENV !== 'production' ? false : {
		dir: Path.join(Dir.toString(), 'coverage')
	}
};


//---------------------------------------------------------------------------------- TASKS


Gulp.task('clean-docs', function(callback){
	Del([Dir.docs], callback);
});

Gulp.task('clean', function(callback){
	Del([Dir.build, Dir.coverage], callback);
});

Gulp.task('lint-self', ()=>
	Gulp.src(__filename)
		.pipe(Lint(Config.lint.src))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('lint-test', ['lint-self'], ()=>
	Gulp.src(Route.test)
		.pipe(Lint(Config.lint.test))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('lint', ['lint-self'], ()=>
	Gulp.src(Route.src)
		.pipe(Lint(Config.lint.src))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('test', ['lint-test', 'build'], ()=>
	Gulp.src(Route.test)
		.pipe(Mocha(Config.mocha))
);

Gulp.task('docs', ['clean-docs'], function(){
	return Gulp.src(Route.src)
		.pipe(Docs())
		.pipe(Gulp.dest(Dir.docs));
});

Gulp.task('build', ['clean', 'lint', 'docs'], function(){
	return Gulp.src(Route.src)
		.pipe(SrcSup())
		.pipe(Source.init())
		.pipe(Babel(Config.babel))
		.pipe(Source.write('.')) // inline sourcemaps
		.pipe(Gulp.dest(Dir.build));
});

Gulp.task('watch', ['test'], function(){

	let firstrun = true;

	const onBuild = function(){
		process.stdout.write('\n\n' + Chalk.yellow('Waiting for changes…') + '\n\n');
	};

	Watch(Route.src.concat(Route.test).concat([__filename]), function(){
		let gulp = Gulp.start('test');
		if (!firstrun) return;
		gulp.on('task_stop', function(e){
			if (e.task !== 'test') return;
			firstrun = false;
			onBuild();
		});
	});

	onBuild();
});