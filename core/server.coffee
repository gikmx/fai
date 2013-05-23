# Node modules
HTTP = require 'http'

# NPM modules
Express   = require 'express'
Params    = require 'express-params'
Validator = require 'express-validator'
Assets    = require 'connect-assets'
Mongo     = require 'connect-mongo'
Passport  = require 'passport'

### --------------------------------------------------------------------------------------
	Initialize
-------------------------------------------------------------------------------------- ###
server = Express()

server.set 'views'       , ﬁ.path.views
server.set 'view engine' , 'jade'

### --------------------------------------------------------------------------------------
	Middleware
-------------------------------------------------------------------------------------- ###

if ﬁ.settings.params
	Params.extend server
	for name,param of ﬁ.settings.params
		ﬁ.log.trace "Param #{name}: #{param}"
		server.param name, param

server.configure ->

	# serve static files through the static folder
	server.use '/static', Express.static ﬁ.path.static

	# Allow the use of coffeescript files for JS / connect-assets
	server.use Assets src: ﬁ.path.assets

	# parse body automagically depending on content
	server.use Express.bodyParser()

	# Add methods for requestbody validation
	server.use Validator

	# parse cookies
	server.use Express.cookieParser ﬁ.settings.secret


module.exports = server
