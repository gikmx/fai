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

options = {}

options.route  = '/assets'
options.tmpdir = Path.join OS.tmpDir(), 'fi-assets'
options.regex  = new RegExp ///^#{options.route}/(js|css)/(\S+\.\1)$///

ﬁ.util.dirRemove options.tmpdir if FS.existsSync options.tmpdir
FS.mkdirSync options.tmpdir
ﬁ.log.warn "#{options.tmpdir}"

files = {}

props =
	css:
		ext  : '.css'
		run  : (str, path)->
			paths = [ﬁ.path.assets_css]
			paths.push path if ﬁ.util.isString path
			Stylus(str)
				.set('paths', paths)
				.use(do Nib).render()
		min  : (str)-> CSSo.justDoIt str

	js:
		ext  : '.js'
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

store = (path, filename, content)->
	logs = "#{filename}"

	Zlib.deflate content, (error, buffer)->
		throw new ﬁ.error error.message if error
		FS.writeFile path + '.deflate', buffer, (error)->
			throw new ﬂ.error error.message if error
			ﬁ.log.trace logs + ".deflate"

	Zlib.gzip content, (error, buffer)->
		throw new ﬁ.error error.message if error
		FS.writeFile path + '.gzip', buffer, (error)->
			throw new ﬁ.error error.message if error
			ﬁ.log.trace logs + ".gzip"
	try
		FS.writeFileSync path, content
	catch e
		throw new ﬁ.error e.message
	ﬁ.log.trace logs

for type, ext of (css:'.styl', js:'.coffee')
	path = ﬁ.path['assets_' + type]
	prop = props[type]
	ﬁ.util.dirwalk path, (filename)->
		return if Path.extname(filename) isnt ext
		context  = Path.join path, Path.dirname(filename.replace(path,'')).substring(1)
		content  = FS.readFileSync filename, 'utf-8'
		filename = filename
			.replace(path, '')
			.substring(1)
			.replace(/\//g,'_')
			.replace(ext, prop.ext)
		# parse and obtain result
		content  = prop.run(content, context)
		# minify content
		content  = prop.min(content) if ﬁ.conf.live
		# replace original content, with a pathname.
		p = Path.join options.tmpdir, filename
		#for type,props of types
		store(p, filename, content)
		files[filename] = p

content = props = null

ﬁ.middleware (request, response, next)->
	# continue if not a valid url.
	return next() if not (match = options.regex.exec request.url)


	# houston we have a match, but, does the file exist?
	ext  = match[1]
	name = match[2].replace(".#{ext}", '').replace(/\//g,'_')
	return next() if ﬁ.util.isUndefined(file = files["#{name}.#{ext}"])

	# it does, prepare headers

	accepts = request.headers['accept-encoding']
	accepts = '' if not ﬁ.util.isString accepts

	type = Express.mime.lookup(request.url) + '; charset=utf-8'

	response.setHeader 'Vary'          , 'Accept-Encoding'
	response.setHeader 'Content-Type'  , type

	# serve content according to what browser expects
	encode = ''
	if accepts.match /\bgzip\b/ then encode = 'gzip'
	else if accepts.match /\bdeflate\b/ then encode = 'deflate'

	if encode.length
		response.setHeader 'Content-Encoding', encode
		ext = '.' + encode
	else
		ext = ''

	FS.readFile file + ext, (error, data)->
		throw new ﬁ.error error.message if error
		response.send data

		ext = file = name = accepts = type = encode = request = undefined



module.exports =
	# return the uri for given asset
	uri : (type)-> (name)-> Path.join options.route, type, "#{name}.#{type}"

	# determines if assets exist with given name, if so returns names in array
	has : (name)->
		throw new ﬁ.error "Invalid name." if not ﬁ.util.isString name
		assets = 
			css: []
			js : []

		parts = []
		for part in name.split Path.sep
			parts.push part
			part = parts.join Path.sep

			if FS.existsSync Path.join ﬁ.path.assets_css, "#{part}.styl"
				assets.css.push part

			if FS.existsSync Path.join ﬁ.path.assets_js, "#{part}#{ﬁ.conf.ext}"
				assets.js.push part
		parts = part = undefined
		return assets