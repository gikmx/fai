Underscore = require 'underscore'

module.exports =

	extend:  Underscore.extend

	isDict: (o)->
		ﬁ.util.isObject(o)    and not
		ﬁ.util.isArray(o)     and not
		ﬁ.util.isFunction(o)  and not
		ﬁ.util.isString(o)    and not
		ﬁ.util.isNumber(o)

	isEmpty: (o)->
		return false if not @isDict(o)
		return false for k,v of o when Object::hasOwnProperty.call(o, k)
		return true

	clone: (target)->
		try
			target = JSON.parse JSON.stringify target
		catch e
			throw new ﬁ.error "Cannot clone given element. #{e.message}"
		return target
