'use strict';

/*»	# Fai
	*A simple framework for agile web development.*
«*/

const ﬁ    = require('./core');
const conf = require('./conf');
const pack = require('../package');
const attr = { visible:false, configurable: false, writable:false, enumerable:false };

// Allowed Errors:
conf.errors = [
	Error,           // A generic error
	RangeError,      // value is not in the set of indicated values
	ReferenceError,  // a non-existent variable is referenced
	SyntaxError,     // sintactically invalid code
	TypeError        // value not of expected type
];

module.exports = function fai(){
	// if fai has been already instantiated there's no need of doing this again.
	if (ﬁ.init) return ﬁ.get();
	// set internal unmutable properties.
	ﬁ.set('conf', conf, attr);
	ﬁ.set('init', true, attr);
	ﬁ.set('info', pack, attr);
	// if a custom conf is sent, merge it with the default one.
	if (arguments[0] && arguments[0].constructor === Object)
		Object.assign(conf, arguments[0]);
	// iterate core modules and «use» them in order.
	for (let name of conf.use) ﬁ.use(name, conf[name]);
	// return the instance
	return ﬁ.get();
};