# Node modules
Path = require 'path'
FS   = require 'fs'

help = {}

# make fi modules available on apps
help.module = (name)->
	module = null
	try
		module = require name
	catch e
		throw new ﬁ.error "Could not load module #{name}: #{e.message}"
	return module

# Require a ﬁ module
help.require = (context, name)->
	args = Array::.slice.call arguments
	if args.length is 1
		context = 'lib'
		name    = args[0]
	throw new ﬁ.error 'You must specify a context and a name.' if not context or not name
	throw new ﬁ.error "Invalid context: #{context}."            if not ﬁ.path[context]

	path = Path.join ﬁ.path[context], String name

	try
		require.resolve path
	catch e
		throw new ﬁ.error "Module #{name} does not exist."

	return require path

# Require a whole directory, converting dirnames into objects and files into properties.
help.requireFS = (root)->
	result = {}
	for file in FS.readdirSync root, file
		path = Path.join root, file
		stat = FS.statSync path
		if not stat.isDirectory()
			continue if Path.extname(file) isnt ﬁ.conf.ext
			base = Path.basename file, ﬁ.conf.ext
			result[base] = require path.replace ﬁ.conf.ext, ''
		else result[file] = arguments.callee path
	return result

module.exports = help
