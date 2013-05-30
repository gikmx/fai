middleware = []

# This is the default behaviour for ﬂ, it can be overwritten.
middleware.push (request, response, next)->
	response.removeHeader 'X-Powered-By'
	s = if request.url is '/' then 'root' else request.url
		.replace(/[^a-z0-9]/g,'-')
		.substr(1)
	ﬁ.debug(s)

	next()

module.exports = middleware
