# Node modules
Path = require 'path'
FS   = require 'fs'

Require = (context, name)->
	args = Array::.slice.call arguments
	if args.length is 1
		context = 'lib'
		name    = args[0]
	path = ﬁ.path
	path = path[c] for c in context.split '.' when path
	throw new ﬁ.error "The context '#{context}' was not found in path." if not path
	path = Path.join path, name
	try
		require.resolve path
	catch e
		throw new ﬁ.error "Module #{name} does not exist."

	return require path

# make fi's npm modules available on apps
Require.module = (name)->
	module = null
	try
		module = require name
	catch e
		throw new ﬁ.error "Could not load module #{name}: #{e.message}"
	return module

# Require a whole directory, converting dirnames into objects and files into properties.
Require.fs = (root)->
	result = {}
	for file in FS.readdirSync root, file
		path = Path.join root, file
		stat = FS.statSync path
		if not stat.isDirectory()
			continue if Path.extname(file) isnt ﬁ.path.script.ext
			base = Path.basename file, ﬁ.path.script.ext
			result[base] = require path.replace ﬁ.path.script.ext, ''
		else result[file] = arguments.callee path
	return result


module.exports = Require