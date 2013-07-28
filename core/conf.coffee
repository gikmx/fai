# Node modules
Path = require 'path'
FS   = require 'fs'

# NPM modules
Args = require 'named-argv'

# a port number must be provided
if typeof Args.opts.port isnt 'string' or not parseInt(Args.opts.port)
	throw new ﬁ.error 'Expecting a port number.'

conf      = {}

conf.live = process.env.NODE_ENV is 'production'
conf.env  = if conf.live then 'production' else 'development'

conf.core = FS.realpathSync __dirname + '/..'
conf.root = Path.dirname conf.core

conf.name  = Path.basename(conf.root).replace /[^a-zA-Z0-9]/g,'_'
conf.ext   = Path.extname __filename
conf.proto = 'http'
conf.host  = 'localhost'
conf.port  = parseInt Args.opts.port
conf.url   = "#{conf.proto}://#{conf.host}:#{conf.port}"

conf.debug = typeof __DEBUG__ isnt 'undefined'

module.exports = conf
