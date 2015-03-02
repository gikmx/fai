# I know, this is not recommended, but fuck it.
GLOBAL.ﬁ  = {}
path      = './src/'

# The most basic functionality and settings.
ﬁ.package = require './package'
ﬁ.conf    = require "#{path}conf"
ﬁ.path    = require "#{path}path"
ﬁ.error   = require "#{path}error"
ﬁ.require = require "#{path}require"

ﬁ.util       = ﬁ.require 'core.root', 'util'
ﬁ.middleware = ﬁ.require 'core.root', 'middleware'
ﬁ.log        = ﬁ.require 'core.root', 'log'
ﬁ.app        = ﬁ.require 'core.root', 'app'

process.exit 1

# Setup server
ﬁ.server = ﬁ.require 'core.root', 'server'

# Setup routing methods
ﬁ.routes = ﬁ.require 'core.root', 'routes'

# Allow fi to be extended.
ﬁ.extend = ﬁ.require 'core', 'extend'

# Enable operation pre, mid and post server configuration.
ﬁ.queuePre  = []
ﬁ.queueMid  = []
ﬁ.queuePost = []

# All task needed to run the server
ﬁ.listen = ﬁ.require 'core', 'listen'