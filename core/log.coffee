FS     = require 'fs'
Path   = require 'path'

Parser = require 'ua-parser'
Colors = require 'colors'

LEVEL = if ﬁ.conf.live then 'info' else 'trace'

getMemory  = ->
	mem = []
	mem.push ﬁ.util.bytes(v) for k,v of process.memoryUsage()
	return mem[0]

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

getDate = ->
	d  = new Date()
	to =  d.getTimezoneOffset()
	hr = Math.floor(Math.abs(to)/60)
	tz = d.getTime() + ((hr * (if to < 0 then 1 else -1)) * 3600000)
	return  new Date(tz).toISOString().replace(/[TZ]/g, ' ').trim()

logger = (method, args)->
	args = Array::slice.call(args).join ' '

	if not ﬁ.util.isString method
		throw new ﬁ.error 'Invalid method.' if not ﬁ.util.isDictionary method
		caller = method.caller
		method = method.method

	levels = ['trace', 'debug', 'info', 'warn', 'error']
	colors = [Colors.cyan, Colors.blue, Colors.green, Colors.yellow, Colors.red]
	index  = levels.indexOf method
	allow  = levels.indexOf LEVEL
	level  = levels[index][0].toUpperCase()
	caller = (getCaller() or '') if not ﬁ.util.isString caller
	caller = if caller.length > 0 then "[#{caller}]" else ''
	throw new ﬁ.error "Invalid log method." if index is -1
	return if index < allow

	if ﬁ.conf.live
		head = [level, getDate(), caller].join ' '
		path  = Path.join(ﬁ.path.root,"#{ﬁ.conf.name}.log")
		FS.appendFile path, "#{head} #{args}\n", (e)-> throw new ﬁ.error e.message if e
	else
		head = [level, getDate(), "[#{getMemory()}]", caller].join ' '
		head = colors[index] head
		process.stdout.write "#{head} #{args}\n"


module.exports =
	trace: -> logger 'trace', arguments
	debug: -> logger 'debug', arguments
	info : -> logger 'info' , arguments
	warn : -> logger 'warn' , arguments
	error: -> logger 'error', arguments

	custom: ->
		args   = Array::.slice.call arguments
		method = args.shift()
		logger method, args

	middleware: (request, response, next)->
		parts = []
		if ﬁ.conf.live
			ua = Parser.parse request.headers["user-agent"]
			parts.push request.connection.remoteAddress
			parts.push [ua.ua.toString(), ua.os.toString()].join ', '
		parts.push request.url

		ﬁ.log.custom (method: 'info', caller:request.method), parts.join ' - '
		next()
