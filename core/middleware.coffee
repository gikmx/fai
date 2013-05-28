middleware = []

# This is the default behaviour for ﬂ, it can be overwritten.
middleware.push (request, response, next)->
	response.removeHeader 'X-Powered-By'
	next()

module.exports = middleware
