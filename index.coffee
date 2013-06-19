"use strict"

# Node modules
HTTP = require 'http'
OS   = require 'os'
Path = require 'path'
FS   = require 'fs'

# I know, this is not recommended, but fuck it.
GLOBAL.ﬁ = {}
ﬁ.error  = -> new String "\n" + Array::slice.call(arguments).join('\n') + "\n"
path     = './core/'

ﬁ.about = require './package'

# All paths used throughout ﬁ
ﬁ.path  = require "#{path}path"

# Core configuration
ﬁ.conf  = require "#{path}conf"

# Debugging methods
ﬁ.debug = require "#{path}debug"

# Underscore, on steroids.
ﬁ.util  = require "#{path}util"

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

# Initialize middleware
ﬁ.middleware = ﬁ.require 'core', 'middleware'
ﬁ.middleware (request, response, next)->
	response.removeHeader 'X-Powered-By'

	return next() if ﬁ.conf.live

	s = if request.url is '/' then 'root' else request.url
		.replace(/[^a-z0-9]/g,'-')
		.substr(1)
	ﬁ.debug(s)

	next()

# Enable logs on every request
ﬁ.middleware ﬁ.log.middleware

# Setup server
ﬁ.server = ﬁ.require 'core', 'server'

# Setup routes
ﬁ.routes = ﬁ.require 'core', 'routes'

ﬁ.bundles = {}

# Main
ﬁ.listen = ->

	throw new ﬁ.error 'ﬁ is already listening.' if ﬁ.isListening

	for middleware in ﬁ.middleware.all
		if not ﬁ.util.isFunction middleware
			throw new ﬁ.error 'Expecting a Middleware function.'
		ﬁ.server.use middleware

	for route in ﬁ.routes
		bundle = "[function]"
		if route.bundle
			bundle = route.bundle
			ﬁ.bundles[bundle] = route.route
		route.controls.unshift route.route
		ﬁ.server[route.method].apply ﬁ.server, route.controls
		ﬁ.log.custom (method:'info', caller:'fi'),
			route.method.toUpperCase(), "\"#{route.route}\" > #{bundle}"

	ﬁ.middleware = undefined
	ﬁ.routes     = undefined

	HTTP.createServer(ﬁ.server).listen ﬁ.conf.port
	ﬁ.isListening = true
	ﬁ.debug('listen')

	ﬁ.log.custom (method:'info', caller:"fi"), "Listening on #{ﬁ.conf.url}"
