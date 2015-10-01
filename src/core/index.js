'use strict';

// Node modules
const Path = require('path');

// NPM modules
const Chalk = require('chalk');

module.exports = {

	// basic error handler (will be replaced with the error module)
	error: function(msg='Unknown', err){
		msg = Chalk.red(msg);
		if (err && this.conf.errors.indexOf(err.constructor) !== -1) {
			err.name    = '';
			err.message = `${msg} ${err.message}\n`;
			throw err;
		}
		throw new Error(msg);
	},

	get: function(){
		/*»	## Scope
			Historically `ﬁ` was being used as a global variable, this has been deprecated
			since 0.3.x. If you still want this behaviour you can set the FAI_GLOBAL
			environment to a truthy value.
		*/
		if (process.env.FAI_GLOBAL) GLOBAL.ﬁ = this;
		else return this;
	},

	// register a variable/module on ﬁ instance.
	set: function(key, value, attr={}){
		if (!attr || attr.constructor !== Object) attr = {};
		if (this.conf && this.conf.attr){
			// if the key is defined in conf attributes, use it as base;
			if (this.conf.attr.modules[key])
				attr = Object.assign({}, this.conf.attr.modules[key], attr);
			// extend property attributes, and add the value.
			attr = Object.assign({}, this.conf.attr.default, attr);
		}
		attr = Object.assign({value:value}, attr);
		Object.defineProperty(this, key, attr);
		return value;
	},

	// enable a fai-module.
	use: function(callee, conf={}, attr={}){
		let mod = null;
		let msg = `Invalid module «${callee}».`;
		if (!conf || conf.constructor !== Object) conf = {};
		// if a string was sent, try to require a core module.
		if (callee && callee.constructor === String){
			try { mod = require(Path.join(__dirname, callee)); }
			catch (err){ this.error(msg, err); }
		} else mod = callee;
		// modules can only be functions.
		if (!mod || mod.constructor !== Function){
			let err = `Expected a function, got «${typeof mod}».`;
			this.error(msg, new TypeError(err));
		}
		// this is dumb, but since the «callee» argument normally expects a name string,
		// we have to have a medium to identify modules. And that medium will be
		// naming the functions, all of them, even the ones in the core.
		if (!mod.name)
			this.error(msg, new ReferenceError('Expected a named function.'));
		// instantiate the module
		callee = mod.name.toLowerCase();
		mod    = mod.call(this, conf, callee);
		// validate result
		if (!mod || mod.constructor !== Object){
			let err = `Expected module to return an object, got «${typeof mod}».`;
			this.error(msg, new TypeError(err));
		}
		// set it on ﬁ and return it.
		return this.set(callee, mod, attr);
	}
};