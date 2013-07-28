MongoConnect = require 'connect-mongo'
Express      = require 'express'

Mongo        = ﬁ.require('mongo')


 # Enable flash functionality
middleware = (request, response, next)->
	return next() if not request.session

	request.session._flash = {} if not request.session._flash

	request.flash = (key)->
		return undefined if not key or not request.session._flash
		key = String key
		value = request.session._flash[key]
		if value
			delete request.session._flash[key]
			ﬁ.log.custom (caller:'session:flash:get', method:'debug'), key, ':', value
		return value

	response.flash = (key, value)->
		return -1 if not key or not value
		key = String key
		ﬁ.log.custom (caller:'session:flash:set', method:'debug'), key, ':', value
		return (request.session._flash[key] = value)

	next()


module.exports = (callback)->
	throw new ﬁ.error 'Invalid callback.' if not ﬁ.util.isFunction callback

	Mongo ﬁ.conf.name, (instance, server, database)->

		MongoStore  = MongoConnect Express
		store   = new MongoStore db: instance
		session = Express.session
			key    : ﬁ.conf.name
			secret : ﬁ.settings.app.secret
			store  : store
			cookie : maxAge: new Date Date.now() + + (3600 * 1000 * 24 * 365)
		ﬁ.middleware.append 'session-express', session
		ﬁ.middleware.append 'session', middleware

		callback.call this, store, session, instance, server, database

