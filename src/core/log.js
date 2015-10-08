'use strict';

// NPM modules
const Chalk  = require('chalk');

// Locals
let CONF;

const logger = function(name, ...messages){

	let level = CONF.levels[name];
	let date  = new Date();
	let sep   = ['[', ']'];

	if (!level.enabled) return;

	// find the caller name.
	let fname;
	let prepareStackTrace = Error.prepareStackTrace;
	Error.prepareStackTrace = (error, frames)=> frames;
	let error = new Error();
	error.stack.shift(); // the first one is this function.
	for (let i in error.stack) if ((fname = error.stack[i].getFunctionName())) break;
	if (!fname) fname = 'Unknown';
	else fname = fname.toLowerCase();
	Error.prepareStackTrace = prepareStackTrace;

	// only show those logs that are actually allowed;
	if (!fname.match(CONF.show)) return;

	if (!process[level.type] || process[level.type].constructor.name !== 'WriteStream')
		this.throw(`Invalid «log» write stream: ${level.type}`);

	// we'll only show the first uppercased letter of the method.
	name = name[0].toUpperCase();

	// Show a human readable version of the time.
	// get the difference timezoneoffset, convert it to ms and invert it.
	date = new Date(date.getTime() + (date.getTimezoneOffset() * 60000 * -1))
		.toISOString()
		.replace('T', ' ')
		.replace('Z', '')
		.slice(2);

	// show a string representation of any non-string value.
	for (let i in messages)
		if (messages[i].constructor !== String)
			messages[i] = JSON.stringify(messages[i], null, ' ');

	// Colors should only be used on development.
	if (CONF.colors && process[level.type].isTTY && process.env.NODE_ENV !== 'production'){
		if (!Chalk[level.color] || Chalk[level.color].constructor !== Function)
			this.throw(`Invalid logger color «${level.color}»`);
		name  = Chalk[level.color](name);
		date  = Chalk[level.color](date);
		fname = Chalk[level.color](fname);
		for (let i in sep) sep[i] = Chalk[level.color](sep[i]);
	}

	// write to STDOUT ot STDERR accordingly
	messages = messages.join(' ');
	process[level.type].write(`${name} ${date} ${sep[0]}${fname}${sep[1]} ${messages}\n`);
};

module.exports = function Log(conf){

	// Validation & normalisation
	if (!conf        || conf.constructor        !== Object) conf = {};
	if (!conf.show   || conf.show.constructor   !== String) conf.show = '.*';
	if (!conf.levels || conf.levels.constructor !== Object) conf.levels = {};

	CONF = conf;

	try {
		CONF.show = new RegExp(CONF.show, 'i');
	} catch (e){
		this.throw('Invalid «show» expression.', e);
	}

	let log = Object.create({});

	for (let level of Object.keys(CONF.levels)){
		let attr  = Object.assign({ value: logger.bind(this, level)}, CONF.attr);
		Object.defineProperty(log, level, attr);
	}
	return log;
};
