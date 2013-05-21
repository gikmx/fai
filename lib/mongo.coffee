MongoDB = require 'mongodb'
_       = require 'underscore'

Log = Config.require 'log'

Mongo =

	server   : undefined
	database : undefined
	instance : undefined

	Mongo: (callback)->
		throw new Config.error 'Expecting a callback' if not _.isFunction callback

		Mongo.server = new MongoDB.Server Config.host, 27017,
			auto_reconnect : false
			native_parser  : true

		Mongo.database = new MongoDB.Db Config.name, Mongo.server,
			journal : true
			safe    : false

		Mongo.database.open (error, db)->
			throw new Config.error error if error
			#Log.debug 'Connected to MongoDB.'
			Mongo.instance = db
			callback.call Mongo

module.exports = Mongo
