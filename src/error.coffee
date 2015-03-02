# Node modules
Util = require 'util'
Path = require 'path'
FS   = require 'fs'

# NPM modules
Columnify = require 'columnify'
Coffee    = require 'coffee-script'
Chalk     = require 'chalk'

prepareStackTrace = (error, frames)->
	lines = []
	paths = [
		[ﬁ.package.name, ﬁ.path.root       , Chalk.red      ],
		['app'         , ﬁ.path.script.root, Chalk.red.bold ],
		['native'      , ''                , Chalk.grey     ]
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
			file : color base
			pos  : color "[#{pos[0]}:#{pos[1]}]"
			cont : color cont.trim()

	trace = Columnify lines,
		showHeaders : false
		align       : 'right'
		config      :
			cont: align: 'left'

	name    = Chalk.white.bgRed " #{error.name or 'Error'} "
	message = Chalk.white.bold  " #{error.message} "

	return "\n#{name}#{message}\n\n#{trace}\n"

FiError = ->
	@constructor.super_.prepareStackTrace = prepareStackTrace if not ﬁ.conf.error
	@constructor.super_.apply @, arguments

Util.inherits FiError, Error

FiError.super_.prepareStackTrace = prepareStackTrace if ﬁ.conf.error

module.exports = FiError