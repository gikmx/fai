FS   = require 'fs'
Util = require 'util'

Colors = require 'colors'
Coffee = require 'coffee-script'

Log = undefined

Err = ->
	Log = Config.require 'log' if not Log
	console.log '\n'
	Log.error.apply null, arguments
	return if Config.live
	Err.super_.apply this, arguments

Util.inherits Err, Error

Err.super_.prepareStackTrace = (error, frames)->
	lines = []
	lines.push(pos2source frame) for frame in frames
	lines.splice 0,3
	return "\n" + lines.join("\n") + "\n"

pos2source = (frame)->
	tab  = Array(13).join ' '
	file = frame.getFileName()

	isSource = false
	isEval   = false

	return tab + "[native]".grey if frame.isNative()
	if frame.isEval()
		isEval = true
		legend = '[evalued code]'
		origin = frame.getEvalOrigin()
		# extract parenthesis
		origin = origin.match /\([^\)]+\)/
		return legend if not origin.length
		origin = origin[0].substr(1, origin[0].length - 2).split ':'

		col  = origin.splice(2,1).join('') or '?'
		row  = origin.splice(1,1).join('') or '¿'
		file = origin.splice(0,1).join('') + ' [eval]'.red
	else if not file
		return tab + "[unknown]".grey
	else
		path = file
		row  = '¿' if not (row = frame.getLineNumber())
		col  = '?' if not (col = frame.getColumnNumber())

	pos  = "[#{row}:#{col}]"
	spc  = Array(tab.length - pos.length).join ' '
	file = file
		.replace(Config.path.root, '')
		.replace(Config.ext,'')

	if (npm = file.lastIndexOf('node_modules')) isnt -1
		file = ("[npm]  " + file.substr(npm + 13)).grey
		pos  = pos.grey
	else if file[0] isnt '/'
		file = "[node] #{file}".grey
		pos  = pos.grey
	else
		isSource = true
		if isEval
			pos  = pos.grey
			file = file.grey

	result =  "#{pos}#{spc}#{file}"

	return result if not path

	script = ''
	if isSource
		try
			script = FS.readFileSync path, 'utf-8'
			script = Coffee.compile(script).split('\n')[row-1]
		catch e
			console.info e
			script = ''

		script = script.substr(col-1).red.bold

	return "#{pos.red}#{spc}#{file.red} #{script}"

module.exports = Err
