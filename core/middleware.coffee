stack = []

position = (type, args)->
	args = Array::slice.call args

	subj = args.shift()
	name = args.shift()
	middleware = args.shift()

	throw new ﬁ.error "Invalid middleware subject." if not subj
	throw new ﬁ.error "Invalid middleware name" if not name
	throw new ﬁ.error "Invalid middleware cb." if not ﬁ.util.isFunction middleware

	name   = String name
	subj   = String subj
	found  = false
	for stk,i in stack
		continue if stk.id isnt subj
		found = i
		break
	throw new ﬁ.error "Middleware #{subj} doesn't exist on stack." if found is false

	stk =
		id: name
		fn: middleware

	i = if type is 'after' then i+1 else i-1
	i = 0 if i < 0

	stack.splice i, 0,
		id: name
		fn: middleware


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

	after  : -> position.call this, 'after' , arguments
	before : -> position.call this, 'before', arguments

	stack: -> return stack
