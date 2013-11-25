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

# Allow fi to be extended.
ﬁ.extend = ﬁ.require 'core', 'extend'

# Enable operation pre, mid and post server configuration.
ﬁ.queuePre  = []
ﬁ.queueMid  = []
ﬁ.queuePost = []

# All task needed to run the server
ﬁ.listen = ﬁ.require 'core', 'listen'