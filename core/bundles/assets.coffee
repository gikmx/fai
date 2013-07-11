# Node modules
OS   = require 'os'
FS   = require 'fs'
Path = require 'path'
Zlib = require 'zlib'

# NPM modules
Coffee  = require 'coffee-script'
Stylus  = require 'stylus'
Nib     = require 'nib'
Uglify  = require 'uglify-js'
CSSo    = require 'csso'
Express = require 'express'

Files = []

# Set a tmp storage dir, and make sure it always starts empty.
tmpdir = Path.join OS.tmpDir(), 'fi-assets'
ﬁ.util.dirRemove tmpdir if FS.existsSync tmpdir
FS.mkdirSync tmpdir
ﬁ.log.warn "#{tmpdir}"

# Set middleware
Route = '/static/assets'
Regex = new RegExp ///^#{Route}/(js|css)/(\S+\.\1)$///

ﬁ.server.use (request, response, next)->

	# continue if not a valid url.
	return next() if not (match = Regex.exec request.url)

	# houston we have a match, but, does the file exist?
	filename = match[2].replace(new RegExp(Path.sep,'g'), '_')

	return next() if ﬁ.util.isUndefined(Files[filename])

	# it does, prepare headers
	filename = Path.join tmpdir, filename
	accepts  = '' if not ﬁ.util.isString(accepts = request.headers['accept-encoding'])

	response.setHeader 'Vary'        , 'Accept-Encoding'
	response.setHeader 'Content-Type', Express.mime.lookup(request.url)+ '; charset=utf-8'

	if ﬁ.conf.live
		# serve content according to what browser expects
		encode = ''
		if accepts.match /\bgzip\b/ then encode = 'gzip'
		else if accepts.match /\bdeflate\b/ then encode = 'deflate'

		if encode.length
			response.setHeader 'Content-Encoding', encode
			filename += ".#{encode}"

	stream = FS.createReadStream filename

	stream.on 'end', ->
		stream = undefined
		response.end()

	stream.pipe(response)
	return

# Set behaviour for asset types
Types =
	css:
		ext  : ['.styl','.css']
		run  : (str, path)-> Stylus(str).set('paths', [path]).use(do Nib).render()
		min  : (str)-> CSSo.justDoIt str

	js:
		ext  : ['.coffee','.js']
		run  : (str)-> Coffee.compile(str)
		min  : (str)->
			code = Uglify.parse str
			code.figure_out_scope()
			str = code.transform Uglify.Compressor(warnings:false)
			str.figure_out_scope()
			str.compute_char_frequency()
			str.mangle_names()
			code = undefined
			return str.print_to_string()


module.exports =

	tree: (name)->
		#diff = (a,b)-> a.filter (x)-> return (b.indexOf(x) < 0)
		names  = name.split '/'
		result =
			css:[]
			js :[]

		return result if not names.length

		parts = []
		while (part = names.shift())
			parts.push part
			for type of Types
				name = parts.join('_')
				continue if not Files[name + ".#{type}"]
				result[type].push name

		return result

	locals: ->
		uri = (type, name)-> Path.join(Route, type, name + '.' + type)
		return (
			css: (name)-> uri('css',name)
			js : (name)-> uri('js', name)
		)

	# Check if given path contains assets with given name and stores them on tmpdir.
	store: (path, name, context)->
		context = ﬁ.path[context]
		context = if context then Path.dirname(context) else ﬁ.path.bundles

		for typename, type of Types

			filename = Path.join path, name + type.ext[0]
			continue if not FS.existsSync filename

			# Get contents and parse them.
			content = FS.readFileSync filename, 'utf-8'
			content = type.run content, path

			filename = filename
				.replace(context, '')
				.substring(1)
				.slice(0,type.ext[0].length * -1)

			# the name is just an identifier, get rid of it, also replace diagonals with
			filename = filename.slice(0,(name.length+1)*-1) if context is ﬁ.path.bundles
			filename = filename.replace(new RegExp(Path.sep,'g'), '_') + type.ext[1]

			# store the filename in an array so we can identify when in request.
			Files[filename] = true

			deflate = (file, cont, callback)->
				# compress using deflate
				Zlib.deflate cont, (error, buffer)->
					path  = Path.join tmpdir, file + '.deflate'
					throw new ﬁ.error error.message if error
					FS.writeFile path, buffer, (error)->
						throw new ﬁ.error error.message if error
						callback.call null, file, cont

			gzip = (file, cont, callback)->
				# compress using gzip
				Zlib.gzip cont, (error, buffer)->
					path  = Path.join tmpdir, file + '.gzip'
					throw new ﬁ.error error.message if error
					FS.writeFile path, buffer, (error)->
						throw new ﬁ.error error.message if error
						callback.call null, file, cont

			normal = (file, cont, callback)->
				FS.writeFile Path.join(tmpdir, file), cont, (error)->
					throw new ﬁ.error e.message if error
					callback.call null, file, cont

			# Minification and compression when in production mode.
			if ﬁ.conf.live
				# minify
				content  = type.min content
				deflate filename, content, (file, cont)->
					ﬁ.log.trace '[deflate] ' + file
					gzip file, cont, (file, cont)->
						ﬁ.log.trace '[gzip] ' + file
						normal file, cont, (file, cont)->
							ﬁ.log.trace file
							file = cont = undefined

			else
				normal filename, content, (file, cont)->
					ﬁ.log.trace file
					file = cont = undefined
			filename = content = undefined