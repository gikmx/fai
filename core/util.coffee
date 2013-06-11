# Node modules
FS     = require 'fs'
Path   = require 'path'
Util   = require 'util'
Crypto = require 'crypto'

# NPM modules
Underscore = require 'underscore'
UUID       = require 'node-uuid'

util = {}

util.extend = Underscore.extend

util.isObject    = Underscore.isObject
util.isArray     = Underscore.isArray
util.isFunction  = Underscore.isFunction
util.isString    = Underscore.isString
util.isNumber    = Underscore.isNumber
util.isUndefined = Underscore.isUndefined

util.isDictionary = (o)->
	util.isObject(o)    and not
	util.isArray(o)     and not
	util.isFunction(o)  and not
	util.isString(o)    and not
	util.isNumber(o)

util.isEmptyDictionary = (o)->
	return false if not util.isDictionary(o)
	for k,v of o
		return false if Object::hasOwnProperty.call(o, k) 
	return true

util.array = {}

util.array.unique = Underscore.uniq

util.dirwalk = (path, callback)->
	throw new ﬂ.error "Expecting a callback function" if not util.isFunction(callback)
	if not FS.existsSync path or not FS.statSync(path).isDirectory()
		throw new ﬁ.error "Invalid Directory. #{path.replace(ﬁ.path.root, '')}"
	for nodeName in FS.readdirSync path
		nodePath = Path.join path, nodeName
		if FS.statSync(nodePath).isDirectory()
			util.dirwalk(nodePath, callback)
			continue
		callback.call null, nodePath

util.bytes = (bytes)->
	sz = ['B', 'KB', 'MB', 'GB','TB']
	return 0 if not bytes
	i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
	return Math.round(bytes / Math.pow(1024, i), 2) + sz[i]

util.uuid = UUID.v4

util.hmac = (str, type)->
	type = 'base64' if not util.isString(type)
	if not util.isDictionary(ﬁ.settings.app) or not util.isString(ﬁ.settings.app.secret)
		throw new ﬁ.error 'Missing app secret setting.' 
	hmac = Crypto.createHmac('sha1', ﬁ.settings.app.secret)
	return hmac.update(str).digest(type)

module.exports = util
