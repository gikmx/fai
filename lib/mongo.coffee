MongoDB = require 'mongodb'

module.exports = (name, callback)->

	throw new ﬁ.error 'Invalid database name.' if not name
	throw new ﬁ.error 'Expecting a callback.' if not ﬁ.util.isFunction callback

	name = String name

	server = new MongoDB.Server ﬁ.conf.host, 27017,
		auto_reconnect : false
		native_parser  : true

	database = new MongoDB.Db name, server,
		journal : true
		safe    : false

	database.open (error, instance)->
		throw new ﬁ.error error.message if error
		ﬁ.log.trace 'Connected to MongoDB'
		callback.call MongoDB, instance, server, MongoDB
