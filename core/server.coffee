# Node modules
HTTP = require 'http'
Path = require 'path'

# NPM modules
Express   = require 'express'
Params    = require 'express-params'
Validator = require 'express-validator'

### --------------------------------------------------------------------------------------
	Initialize
-------------------------------------------------------------------------------------- ###
server = Express()

if ﬁ.settings.params
	Params.extend server
	for name,param of ﬁ.settings.params
		ﬁ.log.trace "Param #{name}: #{param}"
		server.param name, param

server.configure ->

	@set 'views'       , ﬁ.path.views
	@set 'view cache'  , ﬁ.conf.live
	@set 'view engine' , 'jade'

	# serve gziped files through the static folder
	@use Express.compress()
	@use '/static', Express.static ﬁ.path.static

	# allow PUT and DELETE methods
	@use Express.methodOverride()

	# parse body automagically depending on content
	@use Express.bodyParser()

	# Add methods for requestbody validation
	@use Validator

	# parse cookies
	@use Express.cookieParser ﬁ.settings.secret

module.exports = server
