# Node modules
Path = require 'path'
FS   = require 'fs'

# NPM modules
Args = require 'named-argv'

# a port number must be provided
if typeof Args.opts.port isnt 'string' or not parseInt(Args.opts.port)
	throw new ﬁ.error 'Expecting a port number.'

if typeof Args.opts.live isnt 'undefined'
	process.env.NODE_ENV = 'production'

conf      = {}

conf.live = process.env.NODE_ENV is 'production'
conf.env  = if conf.live then 'production' else 'development'

conf.core = FS.realpathSync __dirname + '/..'
conf.root = Path.dirname conf.core

conf.name  = Path.basename(conf.root).replace /[^a-zA-Z0-9]/g,'_'
conf.ext   = Path.extname __filename
conf.proto = if Args.opts.proto isnt 'https' then 'http' else 'https'
conf.host  = if typeof Args.opts.host isnt 'string' then 'localhost' else Args.opts.host
conf.port  = parseInt Args.opts.port
conf.url   = "#{conf.proto}://#{conf.host}:#{conf.port}"

conf.debug = typeof __DEBUG__ isnt 'undefined'

module.exports = conf
