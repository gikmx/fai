# Node modules
Util = require 'util'
Path = require 'path'
FS   = require 'fs'

# NPM modules
Columnify = require 'columnify'
Coffee    = require 'coffee-script'
Chalk     = require 'chalk'

_prepareStackTrace = Error.prepareStackTrace
prepareStackTrace  = (error, frames)->
	lines = []
	paths = [
		['module'      , 'node_modules'    , Chalk.gray     ],
		[ﬁ.package.name, ﬁ.path.root       , Chalk.red      ],
		['app'         , ﬁ.path.script.root, Chalk.red.bold ],
		['native'      , ''                , Chalk.gray     ]
	]
	for frame,i in frames
		file = frame.getFileName()
		continue if file is __filename
		path = Path.dirname file
		base = paths[paths.length-1]
		for p in paths
			continue if not p[1].length or path.indexOf(p[1]) is -1
			base = p
			break
		[type,base,color] = base

		if type is 'module'
			f = file
			e = (Path.extname file).length * -1
			base = f.split('node_modules').slice(1).join(':').replace('/:/',':').slice(1,e)
		else
			base = if base.length then file.replace(base, '') else Path.basename file
			base = base.slice(0, Path.extname(base).length * -1) if base.indexOf('.') isnt -1
		pos  = [do frame.getLineNumber, do frame.getColumnNumber]
		cont = frame.getFunction().toString(ﬁ.conf.charset).split(/[\n\r]/)[pos[0]-1]
		if not cont
			continue if not FS.existsSync file
			cont = FS.readFileSync file, ﬁ.conf.charset
			cont = Coffee.compile(cont) if Path.extname(file).toLowerCase() is '.coffee'
			cont = cont.split(/[\n\r]/)[pos[0]-1]
		cont  = cont.slice(pos[1]-2)
		cont  = cont.slice(0, s) if (s = cont.search /[;{]/) >= 0
		lines.push
			type : color type
			pos  : color "[#{pos[0]}:#{pos[1]}]"
			file : color base
			cont : color cont.trim()

	trace = Columnify lines,
		showHeaders : false
		align       : 'left'
		# config      :
			# cont: align: 'left'
	name    = Chalk.white.bgRed " #{error.name or 'Error'} "
	message = Chalk.white.bold  " #{error.message} "

	return "\n#{name}#{message}\n\n#{trace}\n"

FiError = ->
	@constructor.super_.prepareStackTrace = prepareStackTrace
	args       = Array::slice.call arguments
	name       = args.shift() if args.length > 1
	error      = @constructor.super_.apply @, args
	error.name = name or @constructor.name
	return error

Util.inherits FiError, Error

module.exports          = FiError
Error.prepareStackTrace = _prepareStackTrace
