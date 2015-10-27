'use strict';

// Locals
const BASE = new WeakMap(); // this will hold the BASE of each instance;
const PROP = { enumerable : true };

const Replacer = function(val){
	if (val.indexOf('{') === -1 || val.indexOf('}') === -1) return val;
	let match = val.match(/\{([^\}]+)\}/);
	if (!match || !this[match[1]]) return val;
	return Replacer.call(this, val.replace(match[0], this[match[1]]));
};

module.exports = function Route(conf, callee){
	this.log.trace(`${callee} init`);

	if (!conf || conf.constructor !== Object) conf = {};
	if (!conf.routes || conf.routes.constructor !== Object) conf.routes = {};

	// Define the object that we'll return.
	let route = new String(process.env.PWD);

	// Define the base object, within the instance.
	let base = Object.assign({ fai: this.pwd }, conf.routes);
	BASE.set(route, base);

	// Define getter/setters to be exposed.
	for (let key in base)
		Object.defineProperty(route, key, Object.assign({}, PROP, {
			// returns tha value processed from BASE's instance.
			get: function(){
				let base = BASE.get(this);
				let val = base[key];
				return Replacer.call(base, val);
			},
			// Updates base instance's properties with given value
			set: function(val){
				let base = BASE.get(this);
				base[key] = val;
				BASE.set(this, base);
			}
		}));

	return route;
};