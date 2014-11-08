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

	Request
		url     : url
		method  : method
		body    : JSON.stringify options
		headers :
			'fi-api'          : key
			'Content-Type'    : 'application/json'
			#'Accept-Encoding' : 'gzip, deflate'
		(error, response)->
			throw new ﬁ.error error if error
			body = response.body
			try response.body = JSON.parse response.body catch e
				response.body = [response.body]

			status = response.statusCode
			method = if status is 200 then 'debug' else 'error'
			caller = "API] [#{method}] #{uri} [RESPONSE] [#{status}"
			ﬁ.log.custom (method: method, caller:caller), body

			callback.apply response,
				if status is 200 then [null,response.body] else [response.body]
