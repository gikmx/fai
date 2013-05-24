# Node modules
HTTP = require 'http'
OS   = require 'os'
Path = require 'path'

# I know, this is not recommended, but fuck it.
GLOBAL.ﬁ = {}

path = './core/'

# Simple error handler, will throw errors until the real module is loaded.
ﬁ.error  = -> new String "\n" + Array::.slice.call(arguments).join('\n') + "\n"

# All paths used throughout ﬁ
ﬁ.path  = require "#{path}path"

# Underscore, on steroids.
ﬁ.util  = require "#{path}util"

# Core configuration
ﬁ.conf  = require "#{path}conf"

# Enable logs
ﬁ.log = require "#{path}log"

# Helper methods
ﬁ[name] = helper for name,helper of require "#{path}help"

# Enable custom error with traceback
ﬁ.error = ﬁ.require 'core', 'error'

# Populate settings
ﬁ.settings = ﬁ.require 'core', 'settings'

# Populate locals
ﬁ.locals = ﬁ.require 'core', 'locals'

# Initialize middleware
ﬁ.middleware = ﬁ.require 'core', 'middleware'

# Initializae Asset managament
ﬁ.assets = ﬁ.require 'core', 'assets'

# Setup server
ﬁ.server = ﬁ.require 'core', 'server'


ﬁ.listen = ->
	throw new ﬁ.error 'ﬁ is already listening.' if ﬁ.isListening

	throw new ﬁ.error 'Middleware must be an array.' if not ﬁ.util.isArray ﬁ.middleware
	for middleware in ﬁ.middleware
		if not ﬁ.util.isFunction middleware
			throw new ﬁ.error 'Middlewares can only be functions.'
		ﬁ.server.use middleware

	HTTP.createServer(ﬁ.server).listen ﬁ.conf.port
	ﬁ.log.trace "Listening on #{ﬁ.conf.url}"
	ﬁ.isListening = true

process.on 'uncaughtException', (error)->
  console.log 'Caught exception: ', err
