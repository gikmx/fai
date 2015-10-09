'use strict';

// Node modules
const Path = require('path');

// NPM modules
const Chalk = require('chalk');

// Locals
let CONF;
let ﬁ;

const ORIG = {
	stackTraceLimit   : Error.stackTraceLimit,
	prepareStackTrace : Error.prepareStackTrace
};

// TODO: In some frames, the column number doesn't seem right.

const prepareStackTrace = function(error, frames){
	if (!CONF.stack.enabled) return error;

	for (let frame of frames){
		let filename = frame.getFileName();
		if (filename === __filename) continue;

		let type = {
			node : filename[0] !== Path.sep,
			npm  : filename.indexOf('node_modules') !== -1,
			fai  : filename.indexOf(ﬁ.root) === 0
		};
		type.user = !type.node && !type.npm && !type.fai;

		let prefix  = [];

		if (type.fai) {
			if (!CONF.levels.fai.enabled) continue;
			prefix.push('fai');
			filename = filename.replace(ﬁ.root + Path.sep, '');
		}
		if (type.npm) {
			if (!CONF.levels.npm.enabled) continue;
			prefix.push('npm');
			let modname = 'node_modules';
			filename = filename.slice(filename.lastIndexOf(modname) + modname.length + 1);
			modname = filename.substring(0, filename.indexOf(Path.sep));
			prefix.push(modname);
			filename = filename.slice(modname.length + 1);
		}
		if (type.node) {
			if (!CONF.levels.node.enabled) continue;
			prefix.push('node');
		}
		// TODO: Add validation for type.user
		// TODO: Find out the route the user used to call the script.

		let typename = frame.getTypeName();
		let funcname = frame.getFunctionName();
		let methname = frame.getMethodName();

		if (funcname && funcname.indexOf('.') !== -1){
			funcname = funcname.split('.');
			methname = funcname.pop();
			funcname = funcname.join('');
		}

		if (typename && typename !== funcname) funcname = [typename, funcname].join(' ');
		if (methname) funcname = [funcname, methname]
			.join('.')
			.replace('..','.')
			.replace('.(',' (');

		if (!funcname) funcname = 'anonymous';
		let ctext = [filename, frame.getLineNumber(), frame.getColumnNumber()].join(':');
		funcname = funcname
			.trim()
			.replace('(anonymous function)', 'anonymous')
			.replace(' ', ':');
		funcname = `«${funcname}»`;

		prefix = prefix.join(':');
		if (prefix.length) {
			prefix = `[${prefix}]`;
			if (type.node) prefix = Chalk[CONF.levels.node.color](prefix);
			if (type.fai) prefix = Chalk[CONF.levels.fai.color](prefix);
			if (type.npm) prefix = Chalk[CONF.levels.npm.color](prefix);
		}

		ctext = `${prefix} ${funcname} ${ctext}`;

		console.info(ctext);
	}
	process.exit(0);
	return error;
};

class Exception extends Error {
	constructor(message){
		super(message);
		// TODO: Add validations to stack && stack.limit && stack.levels
		Error.stackTraceLimit   = CONF.stack.limit;
		Error.prepareStackTrace = prepareStackTrace;

		this.name    = this.constructor.name;
		this.message = message;
		this.stack   = (new Error(message)).stack;

		Error.stackTraceLimit   = ORIG.stackTraceLimit;
		Error.prepareStackTrace = ORIG.prepareStackTrace;
	}
}

class FaiError extends Exception {
	constructor(message){
		super(message);
	}
}

module.exports = function Throw(conf, callee){
	this.log.trace(`${callee} init`);

	CONF = conf;
	ﬁ    = this;

	Object.assign(conf.attr, {value: FaiError});
	Object.defineProperty(this.throw, 'FaiError', conf.attr);

	return this.throw;
};