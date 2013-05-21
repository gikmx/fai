Path   = require 'path'
_      = require 'underscore'
Log4JS = require 'log4js'

pattern = if Config.live then "%[[%d] %p:%] %m" else "%[[%d] %x{mem} [%c] %p:%] %m"

Log4JS.configure appenders: [
	type: "console",
	layout:
		type: "pattern",
		pattern: pattern,
		tokens:
			mem : ()->
				mem = Math.ceil(process.memoryUsage().heapUsed / 1048576)
				return "[#{mem}MB]"
]

Log4JS.loadAppender 'file'
appender = Log4JS.appenders.file Path.join(Config.path.root, 'output.log')

Log4JS.addAppender appender, Config.name
Log = Log4JS.getLogger Config.name
Log.setLevel if Config.live then 'INFO' else 'TRACE'

getCaller = ->
	prepareStackTrace = Error.prepareStackTrace
	Error.prepareStackTrace = (_, stack)-> return stack
	stacks = new Error().stack
	stacks.splice 0,2
	Error.prepareStackTrace = prepareStackTrace
	try
		base = stack[3].receiver.filename.replace Config.path.root, ''
	catch e
		base = Config.path.core.replace Config.path.root, ''
	base = base.replace Path.extname(base), ''
	return base

logger = (method, args)->
	Log.category = getCaller() if not Config.live
	Log[method].apply Log, Array.prototype.slice.call args

module.exports =
	trace: -> logger 'trace', arguments
	debug: -> logger 'debug', arguments
	info : -> logger 'info' , arguments
	warn : -> logger 'warn' , arguments
	error: -> logger 'error', arguments
