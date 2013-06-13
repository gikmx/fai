# Node modules
QueryS = require 'querystring'


# This method will respond a JSON whenever a request finishes.
module.exports = (control)-> return (request, response, next)->
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

	API       = false
	challenge = false
	
	# extract API value from request
	if (request.method is 'GET' or request.method is 'DELETE') 
		if not ﬁ.util.isUndefined(request.query.API)
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

	# sanitize request body
	request.sanitize(k).xss() for k,v of request.body

	# log request 
	#opts = (method:'info', caller:'API:' + request.method)
	#ﬁ.log.custom opts, url, QueryS.stringify(request.body)

	# callback time
	control.call control, request, response