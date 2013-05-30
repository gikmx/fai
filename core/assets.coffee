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
options.tmpdir = OS.tmpDir() + options.route.substr 1

FS.mkdirSync options.tmpdir if not FS.existsSync options.tmpdir

types =
	css:
		file : ﬁ.util.getDirContent ﬁ.path.assets_css, '.styl'
		ext  : '.css'
		run  : (str)-> Stylus(str).use(do Nib).render()
		min  : (str)-> CSSo.justDoIt str

	js:
		file : ﬁ.util.getDirContent ﬁ.path.assets_js, '.coffee'
		ext  : '.js'
		run  : (str)-> Coffee.compile(str)
		min  : (str)->
			code = Uglify.parse str
			code.figure_out_scope()
			str = code.transform Uglify.Compressor()
			str.figure_out_scope()
			str.compute_char_frequency()
			str.mangle_names()
			code = undefined
			return str.print_to_string()

store = (type)->
	for name, content of type.file
		try
			name    = name.replace(/\//g,'_')
			content = type.run(content)
			content = type.min(content) if ﬁ.conf.live
			content = new Buffer(content, 'utf-8')
			type.file[name] = Path.join options.tmpdir, "#{name}#{type.ext}"

			Zlib.gzip content, (error, content)->
				throw new ﬁ.error error.message if error
				FS.writeFileSync type.file[name] + '.gzip', content

			Zlib.deflate content, (error, content)->
				throw new ﬁ.error error.message if error
				FS.writeFileSync type.file[name] + '.deflate', content

			FS.writeFileSync type.file[name]
			ﬁ.log.trace "#{name}#{type.ext} stored."
		catch e
			throw new ﬁ.error "[#{name}] #{e.message}"

store(type) for name,type of types
regx = new RegExp ///^#{options.route}/(js|css)/(\S+\.\1)$///

ﬁ.middleware (request, response, next)->
	match = regx.exec request.url

	# continue if not a valid url.
	return next() if not match

	# houston we have a match, but, does the file exist?
	ext  = match[1]
	file = types[ext].file
	name = match[2].replace(".#{ext}", '').replace(/\//g,'_')
	return next() if ﬁ.util.isUndefined file[name]

	accepts = request.headers['accept-encoding']
	accepts = '' if not ﬁ.util.isString accepts

	type = Express.mime.lookup(request.url) + '; charset=utf-8'

	response.setHeader 'Vary'          , 'Accept-Encoding'
	response.setHeader 'Content-Type'  , type

	file   = file[name]
	encode = ''

	if accepts.match /\bgzip\b/ then encode = 'gzip'
	else if accepts.match /\bdeflate\b/ then encode = 'deflate'

	if encode
		response.setHeader 'Content-Encoding', encode
		ext = '.' + encode
	else
		ext = ''

	FS.readFile file + ext, (err, data)->
		throw new ﬁ.error err.message if err
		response.send data

		ext = file = name = accepts = type = encode = request = undefined

module.exports =
	js  : (name)-> "/assets/js/#{name}.js"
	css : (name)-> "/assets/css/#{name}.css"
