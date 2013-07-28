stack = []

handle = (type, args)->
	args = Array::slice.call args
	name       = args.shift()
	middleware = args.shift()
	throw new ﬁ.error "Invalid middleware name." if not name
	throw new ﬁ.error "Invalid middleware." if not ﬁ.util.isFunction middleware

	ware =
		id: String name
		fn: middleware

	if type is 'append'
		stack.push ware
	else if type is 'prepend'
		stack.unshift ware

	log = if not ﬁ.log then console.log else ﬁ.log.trace
	log "Middleware '#{name}' was #{type}ed."


module.exports =

	prepend : -> handle.call this, 'prepend', arguments
	append  : -> handle.call this, 'append' , arguments

	override: (name, middleware)->
		throw new ﬁ.error "Invalid middleware name." if not name
		throw new ﬁ.error "Invalid middleware cb." if not ﬁ.util.isFunction middleware
		name = String name
		stack.map (stk, index)->
			if stk.id is name
				stk.fn = middleware.call(middleware, stk.fn)
				if not ﬁ.util.isFunction stk.fn
					throw new ﬁ.error 'Invalid middleware overrider.'
			return stk

	stack: ->
		middlewares = []
		middlewares.push middleware.fn for middleware in stack
		return middlewares
