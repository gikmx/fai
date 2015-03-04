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
	request.ﬁ = response.ﬁ = {}
	response.removeHeader 'X-Powered-By'
	next()

if ﬁ.app.params
	Params.extend server
	for name,param of ﬁ.app.params
		ﬁ.log.trace "Param #{name}: #{param}"
		server.param name, param

server.configure ->

	@set 'view cache'  , ﬁ.conf.live
	@set 'view engine' , 'jade'

	# serve gziped files through the static folder
	@use Express.compress()
	@use '/static', Express.static ﬁ.path.app.static

	# parse cookies
	@use Express.cookieParser()

	# parse body automagically depending on content
	@use Express.bodyParser()

	# allow PUT and DELETE methods
	@use Express.methodOverride()

	# Add methods for requestbody validation
	@use Validator

server.locals = ﬁ.app.locals

module.exports = server
