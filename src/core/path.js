'use strict';

/*»	# Fai.Path
	*Path variables.*
«*/

const PATH = require('path');
const FS   = require('fs');
const OS   = require('os');

const Props   = {};
const Methods = {};

Props.core = __dirname;
Props.base = PATH.dirname(process.argv[1]);
Props.temp = PATH.join(OS.tmpDir(), 'fai', PATH.basename(Props.base));

Methods.get = function(){
	let args = Array.prototype.slice.call(arguments);
	let base = args.shift() || 'core';
	if (!args.length) return this[base] ? String(this[base]) : null;
	// console.info(this[base], PATH.join.apply(PATH, args));
	// if (typeof this[base][dir]) return null;
	// return this[base][dir];
};

module.exports = function(){

	let path = this;

	for (let key in this){

		path[key] = new String(this[key]);
		let dir = String(path[key]);

		if (!FS.existsSync(dir)) continue;

		for (let item of FS.readdirSync(dir)){
			let full = PATH.join(dir, item);
			if (!FS.lstatSync(full).isDirectory() || !item.match(/(^[a-z][a-z0-9_]+$)/g))
				continue;
			path[key][item] = full;
		}
	}

	for (let key in Methods) this[key] = Methods[key];

	return path;

}.call(Props);
