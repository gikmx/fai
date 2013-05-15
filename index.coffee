Path = require 'path'
FS   = require 'fs'
Args = require 'named-argv'

_ = require 'underscore'

if not _.isString Args.opts.port or not parseInt(Args.opts.port)
	throw new Error 'Expecting a port number.'

self      = {}

self.live = process.env.NODE_ENV is 'production'
self.env  = if self.live then 'production' else 'development'

self.name  = Path.basename Path.dirname __dirname
self.ext   = Path.extname __filename
self.proto = 'http'
self.host  = 'localhost'
self.port  = parseInt Args.opts.port
self.url   = "#{self.proto}://#{self.host}:#{self.port}"

self.path          = {}
self.path.core     = __dirname
self.path.root     = Path.dirname self.path.core
self.path.library  = Path.join self.path.core     , 'lib'
self.path.app      = Path.join self.path.root     , 'app'
self.path.config   = Path.join self.path.root     , 'config'
self.path.frontend = Path.join self.path.app      , 'frontend'
self.path.backend  = Path.join self.path.app      , 'backend'
self.path.views    = Path.join self.path.frontend , 'views'
self.path.static   = Path.join self.path.frontend , 'static'
self.path.assets   = Path.join self.path.frontend , 'assets'
self.path.controls = Path.join self.path.backend  , 'controls'

# requiring HELPERS
self.require = (context, name)->
	args = Array.prototype.slice.call arguments
	if args.length is 1
		context = 'library'
		name    = args[0]
	throw new Error 'Missing arguments.' if not context or not name
	throw new Error "Invalid context: #{context}" if not self.path[context]
	return require Path.join self.path[context], String(name)

self.requireFS = (root)->
	result = {}
	for file in FS.readdirSync root, file
		path = Path.join root, file
		stat = FS.statSync path
		if not stat.isDirectory()
			continue if Path.extname(file) isnt self.ext
			base = Path.basename file, self.ext
			result[base] = require path.replace self.ext, ''
		else result[file] = arguments.callee path
	return result

self.isRealObject = (o)-> _.isObject(o) and
	not _.isUndefined(o)                and
	not _.isArray(o)                    and
	not _.isFunction(o)


GLOBAL.Config = self
# Obtain config from Filesystem
GLOBAL.Config = _.extend self, self.requireFS self.path.config

if _.isUndefined Config.core
	throw new Error 'Expecting core configuration.'

if not _.isString Config.core.secret
	throw new Error 'Expecting a secret phrase on Config.core.'

module.exports = Config
