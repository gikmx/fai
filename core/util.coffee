# Node modules
FS   = require 'fs'
Path = require 'path'
Util = require 'util'

# NPM modules
Underscore = require 'underscore'

util = Underscore.extend {}, Underscore

util.isDictionary = (o)->
	util.isObject(o)    and not
	util.isArray(o)     and not
	util.isFunction(o)  and not
	util.isString(o)    and not
	util.isNumber(o)

# get files from specified directory and retrieve their content
util.getDirContent = (root, ext)->
	ext    = ﬁ.conf.ext if not ext
	result = {}
	try
		dir = FS.readdirSync root
	catch e
		throw new ﬁ.error e.message
	return result if not util.isString root
	for file in dir
		path = Path.join root, file
		continue if Path.extname(file) isnt ext
		result[Path.basename(file,ext)] = FS.readFileSync path, 'utf-8'
	return result

util.bytes = (bytes)->
	sz = ['B', 'KB', 'MB', 'GB','TB']
	return 0 if not bytes
	i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
	return Math.round(bytes / Math.pow(1024, i), 2) + sz[i]

module.exports = util