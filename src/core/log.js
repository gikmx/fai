'use strict';

// Node modules

// NPM modules
const Chalk  = require('chalk');

// Local variables
const LEVELS = {
	trace : { fn:console.info, color: Chalk.cyan	 },
	debug : { fn:console.info, color: Chalk.blue   },
	info  : { fn:console.info, color: Chalk.green  },
	warn  : { fn:console.error, color: Chalk.yellow },
	error : { fn:console.error, color: Chalk.red    }
};

const logger = function(name, ...messages){
	let level   = LEVELS[name];
	let message = level.color(messages.join(' '));
	level.fn(`${message}\n`);
};

module.exports = function Log(conf, callee){

	let levels = Object.keys(LEVELS);
	let log    = Object.create({});

	for (let i in levels){
		let level = levels[i];
		let attr  = Object.assign({ value: logger.bind(log, level)}, conf.attr);
		Object.defineProperty(log, level, attr);
	}

	return log;
};
