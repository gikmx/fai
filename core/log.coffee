Path   = require 'path'
Log4JS = require 'log4js'

pattern = if ﬁ.conf.live then "%[%p [%d] %] %m" else "%[%p [%d] %x{mem} [%c] %] %m"

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
appender = Log4JS.appenders.file Path.join(ﬁ.path.root, 'output.log')

Log4JS.addAppender appender, ﬁ.conf.name
Log = Log4JS.getLogger ﬁ.conf.name
Log.setLevel if ﬁ.conf.live then 'INFO' else 'TRACE'

getCaller = ->
	prepareStackTrace = Error.prepareStackTrace
	Error.prepareStackTrace = (error, frames)-> return frames
	frames = new Error().stack
	Error.prepareStackTrace = prepareStackTrace
	for frame,i in frames
		path = frame.getFileName()
		continue if not path or path is __filename
		path = path
			.replace(ﬁ.path.root, '')
			.replace(ﬁ.conf.ext,'')
		break
	return if not path then 'unknown' else path


logger = (method, args, caller)->
	Log.category = getCaller() if not ﬁ.conf.live
	Log[method].apply Log, Array.prototype.slice.call args

module.exports =
	trace: -> logger 'trace', arguments
	debug: -> logger 'debug', arguments
	info : -> logger 'info' , arguments
	warn : -> logger 'warn' , arguments
	error: -> logger 'error', arguments
	custom: ->
		args   = Array::.slice.call arguments
		method = args.shift()
		caller = args.shift()
		Log.category = caller
		Log[method].apply Log, args
