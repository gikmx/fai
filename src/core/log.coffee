FS     = require 'fs'
Path   = require 'path'

Parser = require 'ua-parser'
Colors = require 'chalk'

levels = ['trace', 'debug', 'info', 'note', 'warn', 'error']
LEVEL  = String(ﬁ.conf.log).toLowerCase()
if typeof ﬁ.conf.log isnt 'string' or levels.indexOf(LEVEL) is -1
	throw ﬁ.error "The level '#{ﬁ.conf.log}' is not a valid log level."

getCaller = ->
	prepareStackTrace = Error.prepareStackTrace
	Error.prepareStackTrace = (error, frames)-> return frames
	frames = new Error().stack
	Error.prepareStackTrace = prepareStackTrace
	for frame,i in frames
		path = frame.getFileName()
		continue if not path or path is __filename
		path = path
			.replace ﬁ.path.root    , ''
			.replace ﬁ.path.core.ext, ''
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
		throw new ﬁ.error 'Invalid method.' if not ﬁ.util.object.isDict method
		caller = method.caller
		method = method.method

	colors = [
		Colors.cyan, Colors.blue, Colors.green, Colors.gray, Colors.yellow, Colors.red
	]
	index  = levels.indexOf method
	allow  = levels.indexOf LEVEL
	level  = levels[index][0].toUpperCase()
	caller = (getCaller() or '') if not ﬁ.util.isString caller
	caller = if caller.length > 0 then "[#{caller}]" else ''
	throw new ﬁ.error 'Invalid log method.' if index is -1
	return if index < allow

	head = colors[index] [level, getDate(), caller].join ' '
	process.stdout.write "#{head} #{args}\n"

	if ﬁ.conf.live
		path  = Path.join(ﬁ.path.root,"#{ﬁ.conf.name}.log")
		FS.appendFile path, "#{head} #{args}\n", (e)-> throw new ﬁ.error e.message if e


ﬁ.middleware.append 'fi-log', (request, response, next)->
	ip = request.headers['x-forwarded-for'] or request.connection.remoteAddress
	ua = Parser.parse request.headers['user-agent']
	ua = [ua.ua.toString(), ua.os.toString()].join ', '

	log = method:'info', caller:"REQUEST] [#{ip}] #{ua} [#{request.method}"
	ﬁ.log.custom log, request.url

	next()

module.exports =
	trace: -> logger 'trace', arguments
	debug: -> logger 'debug', arguments
	info : -> logger 'info' , arguments
	note : -> logger 'note' , arguments
	warn : -> logger 'warn' , arguments
	error: -> logger 'error', arguments

	custom: ->
		args   = Array::.slice.call arguments
		method = args.shift()
		logger method, args
