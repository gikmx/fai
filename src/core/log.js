'use strict';

// NPM modules
const Chalk  = require('chalk');

// Local;
let CONF;

const logger = function(name, ...messages){

	let level = CONF.levels[name];
	let date  = new Date();
	let sep   = ['[', ']'];

	if (!level.enabled) return;

	if (!process[level.type] || process[level.type].constructor.name !== 'WriteStream')
		this.error('Invalid «log» write stream: ' + level.type);

	// find the caller name.
	let fname;
	let prepareStackTrace = Error.prepareStackTrace;
	Error.prepareStackTrace = (error, frames)=> frames;
	let error = new Error();
	error.stack.shift(); // the first one is this function.
	for (let i in error.stack) if ((fname = error.stack[i].getFunctionName())) break;
	if (!fname) fname = 'unknown';
	else fname = fname.toLowerCase();
	Error.prepareStackTrace = prepareStackTrace;

	// only show those logs that are actually allowed;
	if (!fname.match(CONF.show)) return;

	// we'll only show the first uppercased letter of the method.
	name = name[0].toUpperCase();

	// Show a human readable version of the time.
	// get the difference timezoneoffset, convert it to ms and invert it.
	date = new Date(date.getTime() + (date.getTimezoneOffset() * 60000 * -1)).toISOString()
		// faster than a regex
		.replace('T', ' ')
		.replace('Z', ' ')
		// make there are no spaces on both ends of string.
		.trim()
		// we don't need the full year, remove "20" from "20xx"
		.slice(2);

	// show a string representation of any non-string value.
	for (let i in messages)
		if (messages[i].constructor !== String)
			messages[i] = JSON.stringify(messages[i], null, ' ');

	// Colors should only be used when enabled, on TTYs and in non-productions envs
	if (CONF.colors && process[level.type].isTTY && process.env.NODE_ENV !== 'production'){
		if (!Chalk[level.color] || Chalk[level.color].constructor !== Function)
			this.error(`Invalid logger color «${level.color}»`);
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
		this.error('Invalid «show» expression.', e);
	}

	let level, attr, log = Object.create({});

	for (level of Object.keys(CONF.levels)){
		attr  = Object.assign({ value: logger.bind(this, level)}, CONF.attr);
		Object.defineProperty(log, level, attr);
	}

	return log;
};
