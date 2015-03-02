# NPM modules
Underscore = require 'underscore'

util = {}
path = './util/'

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

# Load all utilities in directory
util[k] = v for k,v of ﬁ.require.fs ﬁ.path.core.util

module.exports = util
