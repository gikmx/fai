MongoDB = require 'mongodb'

module.exports = (name, callback)->

	throw new ﬁ.error 'Invalid database name.' if not name
	throw new ﬁ.error 'Expecting a callback.' if not ﬁ.util.isFunction callback

	ﬁ.conf.mongo = {} if not ﬁ.util.isDictionary ﬁ.conf.mongo

	conf =
		server:
			auto_reconnect: false
			native_parser : true
		database:
			journal: true
			safe   : false

	name = String name
	host = if ﬁ.conf.mongo.host then ﬁ.conf.mongo.host else ﬁ.conf.host
	port = if ﬁ.conf.mongo.port then ﬁ.conf.mongo.port else 27017
	conf = if ﬁ.conf.mongo.conf then ﬁ.conf.mongo.conf else conf

	server   = new MongoDB.Server host, port, conf.server
	database = new MongoDB.Db name, server, conf.database

	database.open (error, instance)->
		throw new ﬁ.error error.message if error
		try
			ﬁ.log.trace 'Connected to MongoDB'
			callback.call MongoDB, instance, server, MongoDB
		catch error
			throw new ﬁ.error error
