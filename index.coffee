# I know, this is not recommended, but fuck it.
GLOBAL.ﬁ = {}

# Temporary error handler
ﬁ.error  = -> new String "\n" + Array::slice.call(arguments).join('\n') + "\n"

path     = './core/'

ﬁ.about = require './package'

# Core configuration
ﬁ.conf  = require "#{path}conf"

# All paths used throughout ﬁ
ﬁ.path  = require "#{path}path"

# Debugging methods
ﬁ.debug = require "#{path}debug"

# Underscore, on steroids.
ﬁ.util  = require "#{path}util"

# A placer were to add middlewares
ﬁ.middleware = require "#{path}middleware"

# Enable logs
ﬁ.log = require "#{path}log"

# Helper methods
ﬁ[name] = helper for name,helper of require "#{path}help"

# Enable custom error with traceback
ﬁ.error = ﬁ.require 'core', 'error'

# Make sure default files exist
require "#{path}defaults"

# Populate settings
ﬁ.settings = ﬁ.require 'core', 'settings'

# Populate locals
ﬁ.locals = ﬁ.require 'core', 'locals'

# Setup server
ﬁ.server = ﬁ.require 'core', 'server'

# Setup routing methods
ﬁ.routes = ﬁ.require 'core', 'routes'

ﬁ.bundles = {}

# Enable operation pre, mid and post server configuration.
ﬁ.queuePre  = []
ﬁ.queueMid  = []
ﬁ.queuePost = []

# Main
ﬁ.listen = ->

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
	for route in ﬁ.routes.stack()
		bundle = "[function]"
		if route.bundle
			bundle = route.bundle
			ﬁ.bundles[bundle] = route.route

		route.controls.unshift route.route
		ﬁ.server[route.method].apply ﬁ.server, route.controls
		ﬁ.log.custom (method:'debug', caller:"ﬁ:#{route.method.toUpperCase()}"),
			"#{route.route}  →  #{bundle}"

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
