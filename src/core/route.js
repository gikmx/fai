'use strict';

// Locals
const BASE = new WeakMap(); // this will hold the BASE of each instance;
const SELF = {
	// returns tha value processed from BASE's instance.
	get: function route_get(key){
		let base = BASE.get(this);
		let val = base[key];
		return SELF.replace.call(this, val);
	},
	// Updates base instance's properties with given value
	set: function route_set(key, val){
		let base = BASE.get(this);
		// if this is a new property, define its getter/setter
		if (!base[key]) SELF.define.call(this, key);
		// Update/Set base object
		base[key] = val;
		BASE.set(this, base);
	},
	// Replaces «{route properties}» from value.
	replace: function route_replace(val){
		let base = BASE.get(this);
		if (val.indexOf('{') === -1 || val.indexOf('}') === -1) return val;
		let match = val.match(/\{([^\}]+)\}/);
		if (!match || !base[match[1]]) return val;
		val = val.replace(match[0], base[match[1]]);
		return SELF.replace.call(this, val);
	},
	// Defines a public getter/setter
	define: function route_define(key){
		Object.defineProperty(this, key, {
			get : SELF.get.bind(this, key),
			set : SELF.set.bind(this, key),
			// all properties but «/» get to be enumerable
			enumerable : key !== '/',
		})
	}
};

module.exports = function Route(conf, callee){
	this.log.trace(`${callee} init`);

	if (!conf || conf.constructor !== Object) conf = {};
	if (!conf.routes || conf.routes.constructor !== Object) conf.routes = {};

	// Define the object that we'll return.
	let route = new String(process.env.PWD);

	// There's no 'catch-all' for setters/getters, so, we've to do this.
	// Let's hope «Proxy» gets support on Node soon.
	Object.defineProperty(route, 'set', {
		enumerable   : false,
		configurable : false,
		writable     : false,
		value        : SELF.set.bind(route)
	});

	// Define the base object, within the instance.
	let base = Object.assign({ '/': String(route), fai: this.pwd }, conf.routes);
	BASE.set(route, base);

	// Define getter/setters to be exposed.
	for (let key in base) SELF.define.call(route, key);

	return route;
};