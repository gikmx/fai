MongoDB      = require 'mongodb'
MongoConnect = require 'connect-mongo'
Express      = require 'express'

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
			ﬁ.middleware Express.session
				key    : ﬁ.conf.name
				secret : ﬁ.settings.app.secret
				cookie :
					maxAge: new Date(Date.now() + (3600 * 1000 * 24 * 365))
			callback.call Mongo, Mongo.store

		if not Mongo.instance then return Mongo.Mongo(go) else go()

module.exports = Mongo
