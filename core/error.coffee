# Node modules
FS   = require 'fs'
Util = require 'util'
Path = require 'path'

# NPM modules
Colors = require 'colors'
Coffee = require 'coffee-script'

Log = undefined

Err = ->
	Err.super_::isFi = true
	Err.super_.apply this, arguments

Util.inherits Err, Error

prepareStackTrace = Err.super_.prepareStackTrace

Err.super_.prepareStackTrace = (error, frames)->
	console.info '@@@@', Err.super_::.isFi
	lines  = []
	caller = ''
	for frame in frames
		filename = frame.getFileName()
		continue if not filename or filename is __filename
		caller = filename if not caller
		lines.push(pos2log frame)
	caller = 'unknown' if not caller
	# if caller path isnt inside
	if caller.indexOf ﬁ.path.root isnt 0
		caller = Path.basename caller
		prefix = if caller.indexOf 'node_modules' isnt -1 then "@npm/" else "@node/"
		caller = prefix + caller
	else
		caller = caller.replace(ﬁ.path.root, '').replace(ﬁ.conf.ext,'')
	ﬁ.log.custom 'error', caller, error.message
	return "\n" + lines.join("\n") + "\n"

pos2log = (frame)->
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
		.replace(ﬁ.path.root, '')
		.replace(ﬁ.conf.ext,'')

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
