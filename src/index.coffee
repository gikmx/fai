# I know, this is not recommended, but fuck it.
GLOBAL.ﬁ  = {}
path      = './core/'

# The most basic functionality and settings.
ﬁ.package = require '../package'
ﬁ.conf    = require "#{path}conf"
ﬁ.path    = require "#{path}path"
ﬁ.error   = require "#{path}error"
ﬁ.require = require "#{path}require"

# Utility belt
ﬁ.util    = ﬁ.require 'core.root', 'util'
ﬁ.util[k] = v for k,v of ﬁ.require.fs ﬁ.path.core.util

ﬁ.middleware = ﬁ.require 'core.root', 'middleware'
ﬁ.log        = ﬁ.require 'core.root', 'log'
ﬁ.app        = ﬁ.require 'core.root', 'app'

# Setup server
ﬁ.server = ﬁ.require 'core.root', 'server'
ﬁ.routes = ﬁ.require 'core.root', 'routes'

# Enable operation pre, mid and post server configuration.
ﬁ.queuePre  = []
ﬁ.queueMid  = []
ﬁ.queuePost = []

# All task needed to run the server
ﬁ.listen = ﬁ.require 'core.root', 'listen'