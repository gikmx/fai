# Fai (ﬁ)
A NodeJS's framework for practical web development. It provides a lot of shortcuts and eases the life of those involved in development on any kind of web content (even newbies).

It's main purpose is to be readable, as consistent as possible (in web development that's kind of difficult given the amount of technologies involved), but above all things, practical. Everything is wrapped around the idea of facilitating the creation and maitanence of code.

**ﬁ** is really just a wrapper around express, stylus and jade, with a bunch of rules and shortcuts.

## Requirements

#### [Node](http://http://nodejs.org/) v0.9+

Currently ﬁ has only been tested in Mac and linux, any help testing and/or fixing bugs for windows will be greatly appreciated.

#### [CoffeeScript](http://coffeescript.org) v1.9+

Installed as a global module:

	npm install -g coffee-script

#### [Nodemon](https://github.com/remy/nodemon) (optional)

Installed as a global module:

	npm install -g nodemon

#### [BrowserSync](https://github.com/BrowserSync/browser-sync) (optional)

Installed as a global module:

	npm install -g browser-sync


## Installation

Unless you're an experienced Fai developer, is strongly recommended that your rely on our **[Yeoman generator](https://github.com/gikmx/fai.generator)** for building your fist project, it really takes care of everything! just follow these simple instructions.

	# globally install yeoman and fai's generator
	npm install -g yo generator-fai

	# Create the folder you want your project to live in.
	mkdir FiApp && cd $_

	# Lay back and just let Yeoman do the magic for you.
	yo fi

	# Once finished you can start developing by typing:
	npm run watch

	# Or even debugging in diffent browsers by using:
	npm run sync


## Documentation
__TODO__