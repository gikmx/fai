# Node modules
HTTP = require 'http'
Path = require 'path'

# NPM modules
Express   = require 'express'
Params    = require 'express-params'
Validator = require 'express-validator'

server = Express()

# removes express header and enable debug middleware (if needed)
ﬁ.middleware.prepend 'fi-server', (request, response, next)->
	response.removeHeader 'X-Powered-By'

	return next() if ﬁ.conf.live

	ﬁ.debug if request.url is '/' then 'root' else request.url
		.replace(/[^a-z0-9]/g,'-')
		.substr(1)

	next()

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

	# parse cookies
	@use Express.cookieParser()

	# parse body automagically depending on content
	@use Express.bodyParser()

	# allow PUT and DELETE methods
	@use Express.methodOverride()

	# Add methods for requestbody validation
	@use Validator

module.exports = server
