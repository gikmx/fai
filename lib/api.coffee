# Node modules
QueryS = require 'querystring'
Path   = require 'path'
FS     = require 'fs'

# NPM modules
Request = require 'request'


# make sure the path exists
ﬁ.path.api = Path.join ﬁ.path.backend, 'api'
FS.mkdirSync(ﬁ.path.api, '0700') if not FS.existsSync ﬁ.path.api

# determine base path for API calls
ﬁ.conf.api = '/api' if not ﬁ.util.isString ﬁ.conf.api

# This method will respond a JSON whenever a request finishes.
middleware = (control)-> return (request, response, next)->

	validationErrors = request.validationErrors

	request.hasErrors = ->
		return false if not (errors = validationErrors.call request)
		errors = errors.map (error)-> error.msg
		response.render 400, ﬁ.util.array.unique errors
		return true

	response.render = (status, body)->
		status = 0 if not status
		status = parseInt(status, 10)
		response.writeHead status, 'Content-Type': 'application/json'
		response.end JSON.stringify
			success  : status is 200
			response : body

	# extract API value for request
	API       = false
	challenge = false
	if (request.method is 'GET' or request.method is 'DELETE')
		if not ﬁ.util.isUndefined request.query.API 
			API = request.query.API
			request.query.API = undefined
			url = request.originalUrl.replace("API=#{API}",'').slice(0,-1)
			challenge = [request.method, ﬁ.conf.url + url].join(';')
	else
		if not ﬁ.util.isUndefined request.body.API
			API = request.body.API
			request.body.API = undefined
			form = {}
			for k,v of request.body
				continue if v is undefined
				form[k] = v
			url = ﬁ.conf.url + request.originalUrl
			challenge = [request.method, url, QueryS.stringify form].join(';')

	# Validate API from request
	if (
		not API or
		not ﬁ.util.isString(challenge) or
		API isnt (challenge = ﬁ.util.hmac challenge,'hex')
	)
		return response.render 403, 'Sin autorización.'

	control.call control, request, response

# Parse every control defined on the api folder
traverse = (controls, root)->
	root = ﬁ.conf.api + '/' if not root
	for name, control of controls
		path = Path.join(root, name)
		if ﬁ.util.isDictionary(control)
			traverse(control, path)
			continue
		if not ﬁ.util.isFunction control
			throw new ﬁ.error "Non-function API control: #{name}"
		control = new control
		methods = ['get','put','post','delete']
		for method,i in methods
			if ﬁ.util.isFunction(control[method])
				ﬁ.server[method] path, middleware(control[method])
				ﬁ.log.trace "#{method.toUpperCase()} #{path}"
			else
				methods.splice(methods.indexOf(method), 1)
		
		if not methods.length
			throw new ﬁ.error "Non-method API control: #{name}"
	control = root = path = method = methods = null

traverse(api = ﬁ.requireFS ﬁ.path.api)
api = null

# generate a secure call to own API
request = (method, url, options, callback)->
	args = Array::slice.call arguments
	# if no options are being sent, the user can ommit them and send the CB instead
	if args.length is 3 and ﬁ.util.isFunction options
		callback = options
		options  = {}
	options = {} if not ﬁ.util.isDictionary options

	throw new ﬁ.error 'Invalid callback.' if not ﬁ.util.isFunction callback

	return callback.call(null, 'Invalid method name.') if not ﬁ.util.isString method
	return callback.call(null, 'Invalid url.')         if not ﬁ.util.isString url
	return callback.call(null, 'Invalid options.')     if not ﬁ.util.isDictionary options
	
	# convert options to query string in order to send data, following HTTPS specs.
	if not ﬁ.util.isEmptyDictionary(options) and (method is 'get' or method is 'delete')
		url += if url.indexOf('?') is -1 then '?' else '&'
		url += QueryS.stringify options	
		options = {}

	url     = url.substring(1) if url[0] is '/'
	method  = method.toUpperCase()
	url     = [ﬁ.conf.url, ﬁ.conf.api.substring(1), url].join('/')
		
	onResponse = (error, response, body)->
		return callback.call(response, error) if error
		if not ﬁ.util.isString(body) and not ﬁ.util.isArray(body)
			return callback.call response, 'Invalid response body'
		if ﬁ.util.isString(body)
			try
				body = JSON.parse body
			catch e
				ﬁ.log.warn "Response body was not parsed."
		if response.statusCode isnt 200
			body = [body] if not ﬁ.util.isArray(body)
			callback.call(response, body)
		else
			callback.call(response, null, body.response)

	if method is 'GET' or method is 'DELETE'
		challenge = [method, url].join(';')
		API       = ﬁ.util.hmac(challenge,'hex')
		url += (if url.indexOf('?') is -1 then '?' else '&') + "API=#{API}"
		Request (method: method, uri: url), onResponse 
	else
		challenge = [method, url, QueryS.stringify options].join(';')
		options.API = ﬁ.util.hmac challenge, 'hex'
		Request (method:method, uri:url, form:options), onResponse 	

ﬁ.api =
	get    :-> request.apply request, ['get'].concat Array::slice.call arguments
	put    :-> request.apply request, ['put'].concat Array::slice.call arguments
	post   :-> request.apply request, ['post'].concat Array::slice.call arguments
	delete :-> request.apply request, ['delete'].concat Array::slice.call arguments
	#parse  :-> request.apply request, ['parse'].concat Array::slice.call arguments