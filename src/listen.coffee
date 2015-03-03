FS   = require 'fs'
Path = require 'path'

try
	MasterControl = ﬁ.require 'app.master','control'
	throw new ﬁ.error 'Master controller is invalid.' if not ﬁ.util.isFunction MasterControl
catch e
	throw new ﬁ.error 'Master controller is missing.' if e.name is 'FiRequireError'
	throw new ﬁ.error e

module.exports = ->

	return ﬁ.log.warn("A port was not specified, app won't listen.") if not ﬁ.conf.port

	throw new ﬁ.error 'ﬁ is already listening.' if ﬁ.isListening

	# In case some libraries desire to run code before the server enables routes
	(queue() if ﬁ.util.isFunction queue) for queue in ﬁ.queuePre

	ﬁ.server.configure ->

		# Enable middlewares
		for middleware in ﬁ.middleware.stack()
			ﬁ.log.trace "Using middleware: #{middleware.id}"
			@use middleware.fn

		@use MasterControl

	# In case some libraries desire to run code before the server enables routes
	(queue() if ﬁ.util.isFunction queue) for queue in ﬁ.queueMid

	# Enable application routes
	try
		ﬁ.require 'app.root', 'routes'
	catch e
		throw e if e.name isnt 'FiRequireError'
		throw new ﬁ.error "The route file is invalid or missing."

	# Detect if a error catcher has been defined.
	routes = ﬁ.routes.stack()
	len    = routes.length - 1
	error  = false

	ﬁ.bundles = {}
	ﬁ.routes  = {}

	if len > 0 and routes[len].method is 'error'
		routes[len].method = 'get'
		error = routes[len]

	for route,i in routes
		# Setup the controller
		bundle = if route.bundle then route.bundle  else '[function]'
		route.controls.unshift route.route
		ﬁ.server[route.method].apply ﬁ.server, route.controls
		ﬁ.log.custom
			method :'debug',
			caller :"ﬁ:#{route.method.toUpperCase()}",
			"#{route.route}  →  #{bundle}"
		# Setup the bundles object
		ﬁ.bundles[route.bundle] = {} if not ﬁ.bundles[route.bundle]
		ﬁ.bundles[route.bundle][route.method] = route.route
		# Setup the routes object
		ﬁ.routes[route.route] = {} if not ﬁ.routes[route.route]
		ﬁ.routes[route.route][route.method] = route.bundle

	route = i = routes = undefined

	if error
		ﬁ.server.use (errors, request, response, next)->
			request.errors = errors
			error.controls[1].call ﬁ.server, request, response

	# In case some libraries desire to run code before the server starts to listen.
	(queue() if ﬁ.util.isFunction queue) for queue in ﬁ.queuePost

	ﬁ.server.listen(ﬁ.conf.port)

	ﬁ.isListening = true
	delete ﬁ.middleware
	delete ﬁ.queuePre
	delete ﬁ.queueMid
	delete ﬁ.queuePost

	ﬁ.route = ->
		args = Array::slice.call arguments
		bundle = args.shift()
		bundle = if bundle[0] is '/' then bundle.substring(1) else bundle
		method = if typeof args[0] is 'string' then args.shift() else 'get'
		torepl = args.shift()

		return false if not ﬁ.bundles[bundle] or not ﬁ.bundles[bundle][method]
		route = ﬁ.bundles[bundle][method]
		route = route.replace(":#{key}", val) for key,val of torepl
		return route

	ﬁ.log.custom (method:'info', caller:'fi'), "Listening on #{ﬁ.conf.url}"
	FS.writeFileSync Path.join(ﬁ.path.root, 'fi.lastrun'), new Date()
