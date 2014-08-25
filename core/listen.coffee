FS   = require 'fs'
Path = require 'path'

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

		@use ﬁ.require 'templates','control'

	# In case some libraries desire to run code before the server enables routes
	(queue() if ﬁ.util.isFunction queue) for queue in ﬁ.queueMid

	# Enable application routes
	ﬁ.require 'app', 'routes'

	# Detect if a error catcher has been defined.
	stack = ﬁ.routes.stack()
	len   = stack.length - 1
	error = false
	if len > 0 and stack[len].method is 'error'
		stack[len].method = 'get'
		error = stack[len]

	for route in stack
		bundle = "[function]"
		if route.bundle
			bundle = route.bundle
			ﬁ.bundles[bundle] = route.route

		route.controls.unshift route.route
		ﬁ.server[route.method].apply ﬁ.server, route.controls
		ﬁ.log.custom (method:'debug', caller:"ﬁ:#{route.method.toUpperCase()}"),
			"#{route.route}  →  #{bundle}"

	if error
		ﬁ.server.use (errors, request, response, next)->
			request.errors = errors
			error.controls[1].call ﬁ.server, request, response

	# In case some libraries desire to run code before the server starts to listen.
	(queue() if ﬁ.util.isFunction queue) for queue in ﬁ.queuePost

	ﬁ.server.listen(ﬁ.conf.port)

	ﬁ.isListening = true
	delete ﬁ.routes
	delete ﬁ.middleware
	delete ﬁ.queuePre
	delete ﬁ.queueMid
	delete ﬁ.queuePost

	ﬁ.debug('listen')
	ﬁ.log.custom (method:'note', caller:"fi"), "Listening on #{ﬁ.conf.url}"
	FS.writeFileSync Path.join(ﬁ.path.self, "fi.lastrun"), new Date()
