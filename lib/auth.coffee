# Node modules
Path = require 'path'

# NOM modules
Passport = require 'passport'

throw new ﬁ.error 'Missing Auth settings.' if ﬁ.util.isUndefined ﬁ.settings.auth

Settings = {}
URI      = undefined

ﬁ.middleware.after 'fi-session'   , 'passport-init', Passport.initialize()
ﬁ.middleware.after 'passport-init', 'passport-sess', Passport.session()

Passport.serializeUser (user, next)->
	# ﬁ.log.trace 'serializeUser'
	next null, user

Passport.deserializeUser (user, next)->
	# ﬁ.log.trace 'deserializeUser'
	next null, user

Control =
	strategy: (request, response, next)->
		strategy = request.route.path.split('/').slice(-1)[0]
		Passport.authenticate(strategy, Settings[strategy]) request, response, next
		ﬁ.log.trace strategy, 'strategy'

	callback: (request, response, next)->
		strategy = request.route.path.split('/').slice(-2)[0]
		settings = failureRedirect: Path.join(URI, strategy, 'failure')
		Passport.authenticate(strategy, settings) request, response, next
		ﬁ.log.trace strategy, 'callback'


ﬁ.auth = (uri, callback)->

	throw new ﬁ.error 'Invalid base route.' if not ﬁ.util.isString uri
	throw new ﬁ.error 'Invalid callback.' if not ﬁ.util.isFunction callback

	URI = uri

	# Strategy factory
	for strategy, setting of ﬁ.settings.auth

		throw new ﬁ.error "#{strategy}: Missing clientID." if not setting.clientID
		throw new ﬁ.error "#{strategy}: Missing clientSecret." if not setting.clientSecret

		Route =
			strategy : Path.join uri, strategy
			callback : Path.join uri, strategy, 'callback'
			failure  : Path.join uri, strategy, 'failure'

		tokens =
			clientID     : setting.clientID
			clientSecret : setting.clientSecret
			callbackURL  : ﬁ.conf.url + Route.callback
			returnURL    : ﬁ.conf.url + Route.callback

		delete setting.clientID
		delete setting.clientSecret

		try
			Strategy = require("passport-#{strategy}")
		catch e
			throw new ﬁ.error "Passport #{strategy} strategy, not found.\n\n\tRun 'npm install passport-#{strategy}' on app root."

		Strategy = new Strategy.Strategy tokens, (accessToken, refreshToken, user, next)->
			ﬁ.log.trace "#{strategy}:middleware"
			next null, user

		Passport.use Strategy

		Settings[strategy] = setting

		callback.call Strategy, strategy, Route, Control
		ﬁ.log.trace strategy

	return true
