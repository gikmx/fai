# Node modules
QueryS = require 'querystring'
URL    = require 'url'

# NPM modules
Request = require 'request'

Key = require './key'

methods = ['GET','PUT','POST','DELETE']

module.exports = (method, url, options, callback)->

	args   = Array::slice.call arguments

	method = String(do args.shift).toUpperCase()
	url    = String do args.shift

	options = do args.shift
	if typeof options is 'function'
		callback = options
		headers  = {}
		options  = {}
	else
		headers = do args.shift
		if typeof headers is 'function'
			callback = headers
			headers  = {}
		else
			callback = do args.shift

	throw new ﬁ.error 'Invalid callback.'    if not ﬁ.util.isFunction callback
	throw new ﬁ.error 'Invalid options.'     if not ﬁ.util.isDictionary options
	throw new ﬁ.error 'Invalid headers.'     if not ﬁ.util.isDictionary headers
	throw new ﬁ.error 'Invalid method.'      if methods.indexOf(method) is -1

	# discard everything but the path (even the leading slash)
	url = URL.parse(if url[0] is '/' then url.substring(1) else url).path
	# generate the API key hasg
	key = new Key([ﬁ.conf.name, method.toLowerCase(), url].join ';').hash

	uri = url
	url = ["#{ﬁ.conf.proto}://#{ﬁ.conf.host}:#{ﬁ.conf.port}", ﬁ.conf.api.substring(1), url].join '/'
	qry = false

	# convert options to query string in order to send data, following HTTPS specs.
	if not ﬁ.util.isEmptyDictionary(options) and (method is 'GET' or method is 'DELETE')
		url += '?' + QueryS.stringify options
		qry     = options
		options = {}


	ﬁ.log.custom (method : 'trace', caller : "API] [#{method}] #{uri} [REQUEST"),
		JSON.stringify if qry then qry else options

	# TODO : enable GZIP support (request.js does not support it)
	# 'Accept-Encoding' : 'gzip, deflate'

	headers['fi-api']       = key
	headers['Content-Type'] = 'application/json'

	Request
		url     : url
		method  : method
		body    : JSON.stringify options
		headers : headers

		(error, response)->
			throw new ﬁ.error error if error
			body = response.body
			try response.body = JSON.parse response.body catch e
				response.body = [response.body]

			status = response.statusCode
			method = if status < 300 then 'debug' else 'error'
			caller = "API] [#{method}] #{uri} [RESPONSE] [#{status}"
			ﬁ.log.custom (method: method, caller:caller), body

			args = if status isnt 200 then [response.body, null] else [null,response.body]
			callback.apply response, args
