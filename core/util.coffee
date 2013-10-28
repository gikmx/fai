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

util.dirRemove = (path) ->
	try
		files = FS.readdirSync(path)
	catch e
		throw new ﬁ.error e.message
	if files.length > 0
		i = 0
		while i < files.length
			file = path + "/" + files[i]
			if FS.statSync(file).isFile()
				FS.unlinkSync file
			else
				rmRf file
			i++
	FS.rmdirSync path

# traverse recursively the bundles dir
util.dirwalk = (path, callback, isRecursive)->
	throw new ﬁ.error('Expecting callback.') if not util.isFunction callback
	path = String path
	if not FS.existsSync path or not FS.statSync(path).isDirectory()
		throw new ﬁ.error 'Invalid directory.'
	callback.call(null, path) if not isRecursive
	for node in FS.readdirSync path
		node = Path.join path, node
		continue if not FS.statSync(node).isDirectory()
		callback.call null, node
		util.dirwalk node, callback, true

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

# convert a string into an url friendly slug.
util.toSlug = (str)->
	from = "ãàáäâẽèéëêìíïîõòóöôùúüûñç·/_,:;"
	to   = "aaaaaeeeeeiiiiooooouuuunc------"

	str = String(str).replace(/^\s+|\s+$/g, '').toLowerCase()
	str = str.replace new RegExp(char,'g'), to.charAt(i) for char,i in from
	str = str
		.replace(/[^a-z0-9 -]/g, '')
		.replace(/\s+/g,'-')
		.replace(/-+/g,'-')
	return str

# Convert a number into a comma friendly string.
util.addCommas = (str)->
	str = String(str).replace /\B(?=(\d{3})+(?!\d))/g, ","
	return str

# Shuffle an object
util.shuffle = (o) ->
	j = undefined
	x = undefined
	i = o.length

	while i
		j = Math.floor(Math.random() * i)
		x = o[--i]
		o[i] = o[j]
		o[j] = x
	return o

module.exports = util
