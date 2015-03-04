# Node modules
Path = require 'path'

conf = {}

# Defaults
conf.live    = process.env.NODE_ENV is 'production'
conf.name    = Path.basename Path.dirname process.argv[1]
conf.proto   = 'http'
conf.host    = 'localhost'
conf.port    = 9000
conf.url     = "#{conf.proto}://#{conf.host}:#{conf.port}"
conf.charset = 'utf-8'
conf.error   = false   # Should native errors use fi's errors?
conf.log     = 'trace'

# Set arguments from command line.
for arg, i in process.argv.slice(2)
	continue if arg.slice(0, 2) isnt '--'
	arg = arg.slice(2).split('=')
	conf[arg[0]] = arg[1] or true

module.exports = conf