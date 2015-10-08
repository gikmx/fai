'use strict';

// Node modules
const Path = require('path');


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

		let rules = {
			node : filename[0] !== Path.sep,
			npm  : filename.indexOf('node_modules') !== -1,
			fai  : filename.indexOf(ﬁ.root) === 0
		};
		rules.user = !rules.node && !rules.npm && !rules.fai;

		let tname = frame.getTypeName();
		let fname = frame.getFunctionName();
		let mname = frame.getMethodName();

		if (fname && fname.indexOf('.') !== -1){
			fname = fname.split('.');
			mname = fname.pop();
			fname = fname.join('');
		}

		if (tname && tname !== fname) fname = [tname, fname].join(' ');
		if (mname) fname = [fname, mname].join('.').replace('..','.').replace('.(',' (');
		if (!fname) fname = '<anon>';
		let ctext = [filename, frame.getLineNumber(), frame.getColumnNumber()].join(':');
		ctext = `${fname} ${ctext}`;
		console.info(ctext);
	}
	process.exit(0);
	return error;
};

class Exception extends Error {
	constructor(message){
		super(message);
		// TODO: Add validations to stack && stack.limit
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