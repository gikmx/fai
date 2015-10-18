'use strict';

// Locals
const BASE = {};
const PROP = { enumerable : true };

const Replacer = function(val){
	if (val.indexOf('{') === -1 || val.indexOf('}') === -1) return val;
	let match = val.match(/\{([^\}]+)\}/);
	if (!match || !BASE[match[1]]) return val;
	return Replacer(val.replace(match[0], BASE[match[1]]));
};

module.exports = function Route(conf, callee){
	this.log.trace(`${callee} init`);

	// Populate our BASE object, and add fai's root.
	Object.assign(BASE, conf.routes, {fai: this.root});

	// Define the object that we'll return.
	let route = new String(BASE.fai);

	// Define getter/setters to be exposed.
	// Don't iterate BASE, because we don't want a getter/setter for 'fai'
	for (let key in conf.routes)
		Object.defineProperty(route, key, Object.assign({}, PROP, {
			get: ()=> Replacer(BASE[key]),
			set: val => BASE[key] = val
		}));

	return route;
};