/*»
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/gikmx/fai?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=body_badge)
«*/

'use strict';

const Path = require('path');

/*»	# Fai
	*A simple framework for agile web development.*
«*/
const ROOT = Path.resolve(Path.join(__dirname, '..'));
const ﬁ    = require(Path.join(__dirname, 'core'));
const PACK = require(Path.join(ROOT, 'package'));
const CONF = require(Path.join(ROOT, 'fai'));
const ATTR = { configurable: false, writable:false, enumerable:false };

// Allowed Errors:
CONF.errors = [
	Error,           // A generic error
	RangeError,      // value is not in the set of indicated values
	ReferenceError,  // a non-existent variable is referenced
	SyntaxError,     // sintactically invalid code
	TypeError        // value not of expected type
];

module.exports = function fai(){
	// if fai has been already instantiated there's no need of doing this again.
	if (ﬁ.root) return ﬁ.get(arguments[0]);
	// set internal unmutable properties.
	ﬁ.set('conf', CONF, ATTR);
	ﬁ.set('info', PACK, ATTR);
	ﬁ.set('root', ROOT, ATTR);
	// if a custom conf is sent, merge it with the default one.
	if (arguments[0] && arguments[0].constructor === Object)
		Object.assign(CONF, arguments[0]);
	// iterate core modules and «use» them in order.
	for (let name of CONF.use) ﬁ.use(name, CONF[name]);
	ﬁ.throw('soy una prueba de error');
	// return the instance
	return ﬁ.get();
};