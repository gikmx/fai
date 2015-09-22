'use strict';

//--------------------------------------------------------------------------- NODE MODULES

const Path         = require('path');
const FS           = require('fs');
const ChildProcess = require('child_process');

//---------------------------------------------------------------------------- NPM MODULES

const Del    = require('del');
const Chalk  = require('chalk');

const Gulp   = require('gulp');
const Lint   = require('gulp-eslint');
const Source = require('gulp-sourcemaps');
const SrcSup = require('gulp-sourcemaps-support');
const Babel  = require('gulp-babel');
const Mocha  = require('gulp-spawn-mocha');
const Docs   = require('gulp-fai-doc');

//------------------------------------------------------------------------- PATHS & ROUTES

// Does a little simulation of the path library.
if (!FS.existsSync(Path.join(process.env.PWD, 'package.json'))){
	console.info(Chalk.red('Run gulp from project root'));
	process.exit(1);
}

const path = new String(process.env.PWD);

for (let dir of ['src', 'test', 'docs', 'build', 'coverage'])
	Object.defineProperty(path, dir, {
		value        : Path.join(String(path), dir),
		writable     : false,
		enumerable   : true,
		configurable : false
	});

const route = {
	index : Path.resolve(path.build, 'index.js'),
	test  : [Path.join(path.test, '**/*.js')],
	gulp  : [Path.join(path.src, 'gulp/**/*.js')],
	src   : [
		Path.join(path.src, 'core/**/*.js'),
		Path.join(path.src, 'index.js')
	]
};

//-------------------------------------------------------------------------- CONFIGURATION

const Config = {};

Config.lint = {
	src: {
		useEslintrc : true
	},
	test: {
		rulesPath   : [path.test],
		useEslintrc : true
	}
};

Config.babel = {
	optional      : ['runtime'],
	sourceMap     : ['both'],
	blacklist     : ['strict'], // removes use strict
	stage         : 1,
	sourceMapName : '.map',
	sourceRoot    : path.src,
	comments      : false
};

Config.mocha = {
	ui        : 'bdd',
	bail      : true,
	require   : Path.join(__dirname, 'chai'),
	reporter  : 'mocha-unfunk-reporter',
	compilers : 'js:babel/register',
	istanbul  : process.env.NODE_ENV !== 'production' ? false : {
		dir: Path.join(path.toString(), 'coverage')
	}
};


//---------------------------------------------------------------------------------- TASKS


Gulp.task('clean-docs', function(callback){
	Del([path.docs], callback);
});

Gulp.task('clean', function(callback){
	Del([path.build, path.coverage], callback);
});

Gulp.task('lint-self', ()=>
	Gulp.src(__filename)
		.pipe(Lint(Config.lint.src))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('lint-test', ['lint-self'], ()=>
	Gulp.src(route.test)
		.pipe(Lint(Config.lint.test))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('lint', ['lint-self'], ()=>
	Gulp.src(route.src)
		.pipe(Lint(Config.lint.src))
		.pipe(Lint.format())
		.pipe(Lint.failOnError())
);

Gulp.task('test', ['lint-test', 'build'], ()=>
	Gulp.src(route.test)
		.pipe(Mocha(Config.mocha))
);

Gulp.task('docs', ['clean-docs'], function(){
	return Gulp.src(route.src)
		.pipe(Docs())
		.pipe(Gulp.dest(path.docs));
});

Gulp.task('build', ['clean', 'lint'], function(){
	return Gulp.src(route.src)
		.pipe(SrcSup())
		.pipe(Source.init())
		.pipe(Babel(Config.babel))
		.pipe(Source.write('.')) // inline sourcemaps
		.pipe(Gulp.dest(path.build));
});

Gulp.task('watch', function(done){
	let cmd;
	// keep every argument after the gulp command.
	let arg = process.argv.slice(process.argv.indexOf('watch') + 1);
	// but use this command instead.
	arg.unshift('test');
	// this will be run when changes are found
	function onChange(e){
		// if there's a current process, kill it, so it can be restarted.
		if (cmd) cmd.kill();
		// spawn the new process, but keep its stdio in this process instead.
		cmd = ChildProcess.spawn('gulp', arg, { stdio:'inherit' });
		// if there's the need of run a command after the process dies, do it here.
		cmd.on('close', function(){
			console.info('\n', Chalk.yellow('Waiting for changes …'));
		});
	}
	// Watch the source files, plus the test files;
	let src = route.src
		.concat(route.test)
		.concat(route.gulp);
	Gulp.watch(src, onChange);
	onChange();
});




