# Node modules
Path = require 'path'

# NPM modules
Args = require 'named-argv'

# a port number must be provided
if not ﬁ.util.isString Args.opts.port or not parseInt(Args.opts.port)
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

module.exports = conf
