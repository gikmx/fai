MongoDB = require 'mongodb'

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
			throw new ﬁ.error error if error
			#Log.debug 'Connected to MongoDB.'
			Mongo.instance = db
			callback.call Mongo

		return Mongo

module.exports = Mongo
