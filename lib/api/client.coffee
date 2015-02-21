HTTP  = require 'http'
HTTPS = require 'https'

rxSlash = /^\/+|\/+$/g

module.exports = class

	onData = (response, isException)-> (res)->
		return (status:500, response: (message:res.message, error: res)) if isException
		return status: response.statusCode, response:res or response.responseJSON

	Client = ->
		args   = Array::slice.call arguments
		client = HTTP
		method = do args.shift
		path   = [String(do args.shift).trim().replace(rxSlash, '')]
		body   = do args.shift
		conf   = ﬁ.util.extend {}, @settings

		if ﬁ.util.isFunction body
			callback = body
			body     = do args.shift
		else
			callback = do args.shift

		path.unshift conf.path.trim().replace(rxSlash,'') if conf.path

		conf.path   = [''].concat(path.filter Boolean).join '/'
		conf.method = method.toUpperCase()

		if @isSecure
			conf.agent = new HTTPS.Agent conf
			client = HTTPS

		request = client.request conf, (response)->

			response.setEncoding 'utf-8'
			response.responseText = ''

			response.on 'data', (chunk)-> response.responseText += chunk

			response.on 'end', ->
				ﬁ.log.custom
					method: 'trace'
					caller: "API] [#{conf.method}] #{conf.path} [RESPONSE",
					response.statusCode, JSON.stringify response.responseText
				try
					response.responseJSON = JSON.parse response.responseText
				catch
					response.responseJSON =
						message: 'Invalid JSON'
						body   : response.responseText
					response.statusCode = 500
					callback.call response, onData(response), null, response.responseJSON
					return

				if response.statusCode < 300
					callback.call response, null, onData(response), response.responseJSON
				else
					callback.call response, onData(response), null, response.responseJSON

		request.on 'error', (error)->
			callback.call request, onData(error, true), null, error

		# send content if available
		if (conf.method is 'PUT' or conf.method is 'POST') and body
			throw new ﬁ.error 'Expecting JSON body.' if not ﬁ.util.isDictionary body
			request.write JSON.stringify body

		request.end()


	constructor: (@settings, @isSecure)->
		throw new ﬁ.error 'Settings missing.' if not ﬁ.util.isDictionary @settings
		throw new ﬁ.error 'Host missing.' if not ﬁ.util.isString @settings.host
		throw new ﬁ.error 'Port missing.' if not ﬁ.util.isString @settings.host
		@settings.port = 80  if not ﬁ.util.isNumber @settings.port
		@settings.path = '/' if not ﬁ.util.isString @settings.path

	get : (path, body, callback)->
		Client.apply this, ['get'].concat Array::slice.call(arguments)
	put : (path, body, callback)->
		Client.apply this, ['put'].concat Array::slice.call(arguments)
	post : (path, body, callback)->
		Client.apply this, ['post'].concat Array::slice.call(arguments)
	delete : (path, body, callback)->
		Client.apply this, ['delete'].concat Array::slice.call(arguments)
