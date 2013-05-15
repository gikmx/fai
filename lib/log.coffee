Path = require 'path'
_    = require 'underscore'

Log4JS = require 'log4js'
Log4JS.configure appenders: [
	type: "console",
	layout:
		type: "pattern",
		pattern: "%[%p [%x{mem}] [%d] %c %] %m",
		tokens:
			mem : ()->
				Math.ceil(process.memoryUsage().heapUsed / 1048576) + 'MB'
]

Log4JS.loadAppender 'file'
appender = Log4JS.appenders.file Path.join(Config.path.root, 'output.log')

module.exports = (category)->
	if not _.isString(category) or category.indexOf(Config.path.root) isnt 0
		throw "Log expects __filename, got: #{category}"

	category = category.replace Config.path.root + '/', ''
	category = category.replace Config.ext, ''
	category = "[#{category}]"

	Log4JS.addAppender appender, category
	Log = Log4JS.getLogger category
	Log.setLevel if Config.live then 'INFO' else 'TRACE'
	Log.trace ''
	return Log
