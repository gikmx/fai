# Node modules
Path = require 'path'
FS   = require 'fs'

# NPM modules
Coffee = require 'coffee-script'
Uglify = require 'uglify-js'

# Defaults
defaults =
	source: Path.join ﬁ.path.templates, 'scripts'
	public: Path.join ﬁ.path.static, 'scripts'
	minify: false
	coffee:
		bare: true

module.exports = ->
	args = Array.prototype.slice.call arguments

	throw new ﬁ.error 'Arguments missing' if args.length < 1

	options = defaults
	(options[key] = val for key,val of args.shift()) if ﬁ.util.isDictionary args[0]

	callback = args.shift()
	throw new ﬁ.error 'Missing callback' if not ﬁ.util.isFunction callback

	ﬁ.util.dirRemove(options.public) if FS.existsSync options.public

	FS.mkdirSync(options.source) if not FS.existsSync options.source
	FS.mkdirSync(options.public)

	ﬁ.util.dirwalk options.source, (path)->

		for file in FS.readdirSync path
			continue if Path.extname file isnt ﬁ.conf.ext
			try
				js = FS.readFileSync Path.join(path, file)
				js = Coffee.compile(js.toString(), options.coffee)
			catch e
				throw new ﬁ.error "Error reading #{file}\n #{e}"

			dest =
				Path.join path.replace(options.source, options.public), file.replace(ﬁ.conf.ext, '.js')

			if options.minify or ﬁ.conf.live
				try
					js = Uglify.parse js
					js.figure_out_scope()
					js = js.transform Uglify.Compressor(warnings:false)
					js.figure_out_scope()
					js.compute_char_frequency()
					js.mangle_names()
					js = js.print_to_string()
				catch e
					throw new ﬁ.error "Error minifying #{file}\n #{e.message}"

			FS.writeFileSync dest, js

	callback.call null
