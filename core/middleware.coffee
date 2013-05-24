middleware = []

# This is the default behaviour for ﬂ, it can be overwritten.
middleware.push (request, response, next)->

	# Setup Log
	ﬁ.log.info [
		if ﬁ.conf.live then request.connection.remoteAddress else '',
		request.method,
		request.url,
		if ﬁ.conf.live then request.headers["user-agent"] else '',
	].join ' '

	# public local variables
	response.locals = ﬁ.locals

	next()

module.exports = middleware
