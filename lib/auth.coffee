Path = require 'path'

Passport = require 'passport'
_        = require 'underscore'

Log = Config.require('log') __filename

# Strategy factory
# Will instantiate strategies based upon the "Config.auth" property
strategies = []

_.each Config.auth.strategy, (config, name)->
	strategy    = require("passport-#{name}").Strategy

	callbackURL = Config.auth.url.callback

	if callbackURL.indexOf(':strategy') isnt -1
		callbackURL = callbackURL.replace(':strategy', name)

	callbackURL = "#{Config.auth.host}#{callbackURL}"
	options     = _.extend {}, Config.auth.strategy[name],
		callbackURL : callbackURL
		returnURL   : callbackURL

	Passport.use new strategy options,
		(accessToken, refreshToken, user, next)->
			Log.trace "#{name} callback",
				user         : user
				accessToken  : accessToken
				refreshToken : refreshToken
			next null, user
	strategies.push name
	Log.debug "#{name}", options


# Native Serialize methods
Passport.serializeUser (user, next)->
	Log.trace 'serializeUser', user: user
	next null, user

Passport.deserializeUser (user, next)->
	Log.trace 'deserializeUser', user: user
	next null, user


module.exports =
	regex: (-> return new RegExp '^' + strategies.join('|') + '$')

	strategy: (request, response, next)->
		strategy = request.param 'strategy'
		option = {}
		if _.isObject Config.auth.options[strategy]
			options = Config.auth.options[strategy]
		Log.trace 'strategy:', strategy, options
		Passport.authenticate(strategy, options)(request, response, next)

	callback: (request, response, next)->
		strategy = request.param 'strategy'
		options  = failureRedirect: Config.auth.url.failure
		Log.trace 'callback:', strategy, options
		Passport.authenticate(strategy, options)(request, response, next)
