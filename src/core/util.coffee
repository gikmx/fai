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

module.exports = util