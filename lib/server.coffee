### -------------------------------------------------------------------
	Modules
------------------------------------------------------------------- ###

HTTP  = require 'http'
Path  = require 'path'

Express  = require 'express'
Params   = require 'express-params'
Validate = require 'express-validator'
Assets   = require 'connect-assets'
Mongo    = require 'connect-mongo'
Log4JS   = require 'log4js'
Passport = require 'passport'
_        = require 'underscore'

Log     = Config.require('log') __filename
API     = Config.require 'api'
Locals  = Config.require 'locals'
MongoDB = Config.require 'mongo'


### -------------------------------------------------------------------
	Initialize
------------------------------------------------------------------- ###

server = Express()

### -------------------------------------------------------------------
	Settings
------------------------------------------------------------------- ###

server.set 'views'       , Config.path.views
server.set 'view engine' , 'jade'

### -------------------------------------------------------------------
	Middleware
------------------------------------------------------------------- ###

# Params
Params.extend server
Config.params = Config.params()

_.each Config.params, (param, name)->
	Log.debug "Setting parameter #{name} : #{param}"
	server.param name, param

# Database
if MongoDB.instance
	MongoStore =  Mongo Express
	MongoStore =  new MongoStore db: MongoDB.instance

# General configuration
server.configure ()->

	server.use Log4JS.connectLogger Log

	server.use Express.errorHandler
		dumpExceptions : not Config.production
		showStack      : not Config.production

	server.use '/static', Express.static Config.path.static

	server.use Assets src: Config.path.assets

	server.use Express.bodyParser()

	server.use Express.cookieParser Config.secret

	server.use Express.session
		key    : Config.name
		secret : Config.core.secret
		store  : MongoStore
		cookie:
			maxAge : new Date(Date.now() + (3600 * 1000 * 24 * 365))

	server.use Validate

	server.use Passport.initialize()

	server.use Passport.session()

	server.use (request, response, next)->
		# set root according to context
		server.locals = Locals request, response
		response.api  = API request, response

		next()

server.passport = Passport

### -------------------------------------------------------------------
	Start Listening
------------------------------------------------------------------- ###
HTTP.createServer(server).listen Config.port;

Log.debug "Listening on #{Config.url}"

### -------------------------------------------------------------------
	Export
------------------------------------------------------------------- ###

module.exports = server
