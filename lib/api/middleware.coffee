Path = require 'path'

Parser = require 'ua-parser'

Key = require './key'

module.exports = (controls)-> (request, response, next)->

	url    = request.path.replace(ﬁ.conf.api, '').substring(1)
	method = request.method.toLowerCase()

	# ignore everything that's not defined on API
	return next() if (
		request.url.indexOf(ﬁ.conf.api) is -1 or
		not controls[method] or
		not controls[method][url]
	)

	control = controls[method][url]

	# Automatically respond to validation errors-
	request.hasErrors = (skip)->
		return false if not (errors = request.validationErrors.call request)
		errors = ﬁ.util.array.unique errors.map (error)-> error.msg
		response.render(400, errors) if ﬁ.util.isUndefined skip
		return errors

	# override default render so all responses are consistent
	response.render = (status, body)->
		status = 0 if not status
		status = parseInt(status, 10)
		response.writeHead status, 'Content-Type': 'application/json'
		response.end JSON.stringify
			success  : status is 200
			response : body

	key = new Key [ﬁ.conf.name, method, url].join(';')
	ip  = request.headers['x-forwarded-for'] or request.connection.remoteAddress
	ua  = Parser.parse request.headers["user-agent"]
	ua  = if ip is '127.0.0.1' then ' ' else " [#{ip}] #{ua.ua}, #{ua.os} "

	# do authentication unless the control explicitly disables it.
	return response.render(403, ['Sin autorización.']) if not control.public and (
		not request.headers or
		not request.headers['fi-api'] or
		not key.challenge request.headers['fi-api']
	)

	# Sanitize request body
	request.sanitize(k).xss() for k,v of request.body

	ﬁ.log.custom
		method: 'debug'
		caller: "API] [SERVE]#{ua}[#{method.toUpperCase()}",
		url,
		JSON.stringify if method is "get" or "delete" then request.query else request.body

	control.call control, request, response
