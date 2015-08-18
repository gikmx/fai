'use strict';

/*»	# Fai
	*A simple framework for agile web development.*
«*/

/*»	## Scope

	Historically fai (from now on referred as `ﬁ`) has been used as a global variable,
	but from this version on it will be exported normally and only be exposed to the
	global scope when the FAI_GLOBAL environment variable is present.
*/

let ﬁ;

module.exports = ﬁ = {};
if (process.env.FAI_GLOBAL) GLOBAL.ﬁ = ﬁ; //«


/*»	### Package

	The `package.json` file, is conveniently written in JSON, `ﬁ` takes advantage from this
	and requires it as a module so all of its variables are available to you.
*/

ﬁ.package = require('../package'); //«

/*»	## Modules and regulation.

	Modularity in `ﬁ` is (and always will be) the most important part in our development
	process, everything will be break into (usable) parts as much as possible.

	Readibility is a priority for us, you'll spend more time reading code than writing it,
	in order to be truly agile you not only need to write code faster, you also need to
	maintain it fast (and easily). This is why we've set a strict set of rules and code
	structure so every module is easily readable and understandable.

	All of our Modules will always share the same structure, no exceptions. This is super
	important, since we tend to update our methodologies often in order to improve your
	workflow, so, if we're consistent and you're consitent, updating code when a breaking
	change is needed, is going to be as easy as a well-written search and replace.


	### Structure

	- The `'use strict';` statement;
	- Native modules used.
	- NPM modules used.
	- Local modules used.
	- Module to be exported, declared using capitalized variable.
	- Logic.
	- `module.exports` statement;

	### Rules.

	- External modules will always be capitalized constants.
	- The module to be exported will always be a capitalized constant.
	- Spacing in declaration will always be homogeneous.
	- Blocks of logic will always be separated with a new line.
	- We're lazy, so does the evaluation of our code.
	- We Don't repeat ourselves.
	- We Keep it simple, we're not stupid.

	### Core modules

«*/

//»	- `ﬁ.path` Centralises path variables //«
ﬁ.path  = require('./core/path');

console.info(ﬁ.path.get('base', 'app'));
process.exit(0);

// console.info(ﬁ.path);
// require(ﬁ.path.get(ﬁ.path.app));
