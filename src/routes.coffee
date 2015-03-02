Path = require 'path'
FS   = require 'fs'
OS   = require 'os'

Routes   = []
Bundles  = ﬁ.require 'core.root', 'bundles'
hasError = false

enable = ->
	controls = Array::slice.call arguments
	method  = controls.shift()
	route   = controls.shift()

	bundle = null

	throw new ﬁ.error 'Expecting a method.' if not ﬁ.util.isString method
	throw new ﬁ.error 'Expecting a route.' if not ﬁ.util.isString route
	throw new ﬁ.error 'Expecting at least one controller.' if controls.length < 1

	if hasError
		throw new ﬁ.error 'An error handler has been set, no more routes allowed.'

	if method isnt 'error' and not ﬁ.util.isFunction ﬁ.server[method]
		throw new ﬁ.error "Invalid method. (#{method})"

	result = []

	# remaining arguments are controllers or strings pointing to bundles.
	for control in controls
		if ﬁ.util.isString control
			bundle  = control
			control = Bundles(control)
		throw new ﬁ.error 'Invalid bundle.' if not ﬁ.util.isFunction control
		result.push control

	Routes.push
		route    : route
		bundle   : bundle
		method   : method
		controls : result

	hasError = true if method is 'error'

# Enable routing methods for routing file temporarily.
module.exports =

	all    : -> enable.apply enable, ['all'].concat Array::slice.call arguments
	get    : -> enable.apply enable, ['get'].concat Array::slice.call arguments
	post   : -> enable.apply enable, ['post'].concat Array::slice.call arguments
	put    : -> enable.apply enable, ['put'].concat Array::slice.call arguments
	delete : -> enable.apply enable, ['delete'].concat Array::slice.call arguments
	error  : -> enable.apply enable, ['error'].concat Array::slice.call arguments
	stack : -> return Routes
