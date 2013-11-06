# Node modules
QueryS = require 'querystring'
URL    = require 'url'

# NPM modules
Request = require 'request'

Key = require './key'

methods = ['GET','PUT','POST','DELETE']

module.exports = (method, url, options, callback)->

	args   = Array::slice.call arguments
	method = String(method).toUpperCase()

	# if no options are being sent, the user can ommit them and send the CB instead
	if args.length is 3 and ﬁ.util.isFunction options
		callback = options
		options  = {}
	options = {} if not ﬁ.util.isDictionary options

	throw new ﬁ.error 'Invalid callback.'    if not ﬁ.util.isFunction callback
	throw new ﬁ.error 'Invalid options.'     if not ﬁ.util.isDictionary options
	throw new ﬁ.error 'Invalid method.'      if methods.indexOf(method) is -1

	# discard everything but the path (even the leading slash)
	url = URL.parse(if url[0] is '/' then url.substring(1) else url).path
	# generate the API key hasg
	key = new Key([ﬁ.conf.name, method.toLowerCase(), url].join ';').hash

	uri = url
	url = [ﬁ.conf.url, ﬁ.conf.api.substring(1), url].join '/'
	qry = false

	# convert options to query string in order to send data, following HTTPS specs.
	if not ﬁ.util.isEmptyDictionary(options) and (method is 'GET' or method is 'DELETE')
		url += '?' + QueryS.stringify options
		qry     = options
		options = {}


	ﬁ.log.custom
		method : 'trace'
		caller : "API] [REQUEST] [#{method}",
		uri,
		JSON.stringify if qry then qry else options

	Request
		url     : url
		method  : method
		headers : ('fi-api': key),
		(error, response)->
			throw new ﬁ.error error if error

			try
				body = JSON.parse response.body
				body = body.response
			catch e
				body = [response.body]

			ﬁ.log.custom
				method: 'debug'
				caller: "API] #{uri} [#{method}",
				response.statusCode,
				JSON.stringify body

			callback.apply response,
				if response.statusCode is 200 then [null,body] else [body,null]
