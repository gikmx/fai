MongoDB      = require 'mongodb'
MongoConnect = require 'connect-mongo'
Express      = require 'express'

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


Mongo =

	server   : undefined
	database : undefined
	instance : undefined

	Mongo: (callback)->
		throw new ﬁ.error 'Expecting a callback' if not ﬁ.util.isFunction callback

		Mongo.server = new MongoDB.Server ﬁ.conf.host, 27017,
			auto_reconnect : false
			native_parser  : true

		Mongo.database = new MongoDB.Db ﬁ.conf.name, Mongo.server,
			journal : true
			safe    : false

		Mongo.database.open (error, db)->
			throw new ﬁ.error error.message if error
			ﬁ.log.trace 'Connected to MongoDB.'
			Mongo.instance = db
			callback.call Mongo

		return Mongo

	session: (callback)->
		go = ->

			MongoStore  = MongoConnect Express
			Mongo.store = new MongoStore db: Mongo.instance
			session = Express.session
				key    : ﬁ.conf.name
				secret : ﬁ.settings.app.secret
				store  : Mongo.store
				cookie :
					maxAge: new Date(Date.now() + (3600 * 1000 * 24 * 365))
			ﬁ.server.use session
			ﬁ.server.use middleware
			callback.call Mongo, Mongo.store

		if not Mongo.instance then return Mongo.Mongo(go) else go()

module.exports = Mongo
