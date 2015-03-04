Underscore = require 'underscore'


module.exports =

	extend: Underscore.extend

	isEmpty: (o)->
		return false if not util.isDictionary(o)
		for k,v of o
			return false if Object::hasOwnProperty.call(o, k)
		return true

	clone: (target)->
		try
			target = JSON.parse JSON.stringify target
		catch e
			throw new ﬁ.error "Cannot clone given element. #{e.message}"
		return target
