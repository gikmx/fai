# Node modules
FS     = require 'fs'
Util   = require 'util'
Path   = require 'path'
Stream = require 'stream'

# NPM modules
Colors = require 'colors'
Coffee = require 'coffee-script'

Log = undefined

Err = ->
	Err.super_::fi = true
	Err.super_.apply this, arguments

Util.inherits Err, Error

prepareStackTrace = Err.super_.prepareStackTrace

Err.super_.prepareStackTrace = (error, frames)->
	lines   = []
	caller  = false

	for frame in frames
		file = frame.getFileName()
		continue if not file or file is __filename
		line = pos2log frame, file
		if not caller
			context = if line.context is 'app' then '' else "#{line.context}/"
			caller = context + line.file
		lines.push line

	spc = {}
	for i in Object.keys lines[0]
		spc[i] = Math.max.apply null, lines.map (line)-> line[i].length

	buffer = ''
	if this::fi
		# capture logged.error into a string buffer
		stdoutWrite = process.stdout.write
		process.stdout.write = ((write)-> return (string, encoding, fd)->
			buffer += string
		)(process.stdout.write)
		ﬁ.log.custom (method: 'error', caller:caller), error.message
		process.stdout.write = stdoutWrite
	else
		buffer = "ERROR: #{error.message}\n"

	result = "\n#{buffer}\n"
	for line in lines
		for key,prop of line
			tab = Array((spc[key]+3) - prop.length).join(' ')
			if this::fi and line.context isnt 'app'
				prop = prop.grey
			else if this::fi and key is 'script'
				prop = prop.red.bold
			else if this::fi
				prop = prop.red
			result += prop + tab
		result += '\n'

	return result

pos2log = (frame, file)->

	result = pos: '', context: '', file: '', source : '', script: ''
	path   = file

	if (i = file.lastIndexOf('node_modules')) isnt -1
		result.context = 'npm'
		result.file    = file.substr(i + 13).replace Path.extname(file), ''
	else if file.indexOf(ﬁ.path.root) is -1
		result.context = 'node'
		result.file    = Path.basename(file).replace Path.extname(file), ''
	else
		result.context = 'app'
		result.file    = file.replace(ﬁ.path.root, '').replace(ﬁ.conf.ext , '')

	if frame.isNative()
		result.context = 'native'
		return result
	if frame.isEval()
		result.context = 'eval'
		return result

	row  = '¿' if not (row = frame.getLineNumber())
	col  = '?' if not (col = frame.getColumnNumber())

	result.pos = "[#{row}:#{col}]"

	return result if result.context isnt 'app' or not FS.existsSync(path)

	try
		script = FS.readFileSync path, 'utf-8'
		script = Coffee.compile(script).split('\n')[row-1]
		script = script.substr(col-1)
	catch e
		return result

	result.script = script
	return result

module.exports = Err
