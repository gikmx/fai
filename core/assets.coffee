# Node modules
OS   = require 'os'
FS   = require 'fs'
Path = require 'path'

# NPM modules
Coffee = require 'coffee-script'
Stylus = require 'stylus'
Nib    = require 'nib'
Uglify = require 'uglify-js'
CSSo   = require 'csso'

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
			return str.print_to_string()

store = (type)->
	for name, content of type.file
		try
			name    = name.replace(/\//g,'_')
			path    = Path.join options.tmpdir, "#{name}#{type.ext}"
			content = type.run(content)
			content = type.min(content) if ﬁ.conf.live
			type.file[name] = content
			ﬁ.log.trace "Stored asset in memory: #{name}#{type.ext}"
			#ﬁ.log.debug "Compiled and stored asset: #{name}#{type.ext}"
			#FS.writeFileSync type.file[name], content
		catch e
			throw new ﬁ.error "[#{name}] #{e.message}"

store(type) for name,type of types

ﬁ.middleware.push (request, response, next)->
	regx = new RegExp ///^#{options.route}/(js|css)/(\S+\.\1)$///
	match = regx.exec(request.url)
	# continue if not a valid url.
	return next() if not match

	# houston we have a match, but, does the file exist?
	ext  = match[1]
	file = types[ext].file
	name = match[2].replace(".#{ext}", '').replace(/\//g,'_')

	return next() if ﬁ.util.isUndefined file[name]

	response.end file[name]

	###
	try
		data = FS.readFileSync 'hola.txt'
	catch e
		ﬁ.log.error e.message
		return next()
	###


module.exports =

	js: (name)->
		console.info name
	css: (name)->
		console.info name
