'use strict';

// Node modules

// NPM modules
const Chalk  = require('chalk');

// TODO: Define allowed levels.

// Local variables
// TODO: Levels should be defined from the configuration file.
const LEVELS = {
	trace : { type:'stdout', color: Chalk.cyan  },
	debug : { type:'stdout', color: Chalk.blue  },
	info  : { type:'stdout', color: Chalk.green },
	warn  : { type:'stderr', color: Chalk.yellow },
	error : { type:'stderr', color: Chalk.red    }
};

let Conf;
const logger = function(name, ...messages){

	let level = LEVELS[name];
	let date  = new Date();
	let sep   = '»';

	name = name[0].toUpperCase();

	// find the caller name.
	let fname;
	let prepareStackTrace = Error.prepareStackTrace;
	Error.prepareStackTrace = (error, frames)=> frames;
	let error = new Error();
	error.stack.shift(); // the first one is this function.
	for (let i in error.stack) if ((fname = error.stack[i].getFunctionName())) break;
	if (!fname) fname = 'Unknown';
	Error.prepareStackTrace = prepareStackTrace;

	// only show those logs that are actually allowed;
	if (!fname.match(Conf.use)) return;

	// Show a human readable version of the time.
	// TODO: Simplify and optimise these lines.
	let to = date.getTimezoneOffset();
	let hr = Math.floor(Math.abs(to) / 60);
	let tz = date.getTime() + (hr * (to < 0 ? 1 : -1) * 3600000);
	date = new Date(tz).toISOString().replace(/[TZ]/g, ' ').trim();

	// show a string representation of any non-string value.
	for (let i in messages)
		if (messages[i].constructor !== String)
			messages[i] = JSON.stringify(messages[i], null, ' ');

	// Colors should only be used on development.
	if (process.env.NODE_ENV !== 'production' && Conf.colors){
		name  = level.color(name);
		date  = level.color(date);
		fname = level.color(fname);
		sep   = level.color(sep);
	}

	// write to STDOUT ot STDERR accordingly
	messages = messages.join(' ');
	process[level.type].write(`${name} ${date} ${fname} ${sep} ${messages}\n`);
};

module.exports = function Log(conf){

	let levels = Object.keys(LEVELS);
	let log    = Object.create({});

	Conf     = conf;
	Conf.use = new RegExp(Conf.use, 'i');

	for (let i in levels){
		let level = levels[i];
		let attr  = Object.assign({ value: logger.bind(log, level)}, Conf.attr);
		Object.defineProperty(log, level, attr);
	}
	return log;
};
