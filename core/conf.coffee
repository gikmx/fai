# Node modules
Path = require 'path'

# NPM modules
Args = require 'named-argv'

# a port number must be provided
if typeof Args.opts.port isnt 'string' or not parseInt(Args.opts.port)
	throw new ﬁ.error 'Expecting a port number.'

conf      = {}

conf.live = process.env.NODE_ENV is 'production'
conf.env  = if conf.live then 'production' else 'development'

conf.name  = Path.basename ﬁ.path.root
conf.ext   = Path.extname __filename
conf.proto = 'http'
conf.host  = '127.0.0.1'
conf.port  = parseInt Args.opts.port
conf.url   = "#{conf.proto}://#{conf.host}:#{conf.port}"

conf.debug = typeof __DEBUG__ isnt 'undefined'

module.exports = conf
