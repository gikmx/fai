HTTPS = require 'https'

connect = (path, config, callback, method)->

	config = {} if not ﬁ.util.isDictionary config

	throw new ﬁ.error 'Expecting callback.' if not ﬁ.util.isFunction callback

	yConf = ﬁ.settings.yapp
	# Populate config, base upon global environment config
	for key, val of yConf
		if ﬁ.util.isDictionary val
			config[key] = ﬁ.util.extend {}, val, config[key]
		else
			continue if not ﬁ.util.isUndefined config[key]
			config[key] = val

	config.path    = yConf.path + String(path)
	config.method  = method
	config.agent   = new HTTPS.Agent config

	request = HTTPS.request config,
		(response)->
			response.setEncoding 'utf-8'
			data = ''

			response.on 'data', (chunk)-> data += chunk

			response.on 'end', ()->
				res = null
				try
					res = JSON.parse data
				catch e
					ﬁ.log.warn "Response could not be parsed as JSON."
					res = response: data

				config.path = config.path.replace "#{yConf.path}/", ''

				ﬁ.log.custom
					method: 'trace'
					caller: "YAPP] [#{config.method}] #{config.path} [RESPONSE",
					response.statusCode,
					JSON.stringify res

				if response.statusCode is 200
					callback.call null, null, response.statusCode, res
				else
					callback.call null, res, response.statusCode

	request.on 'error', (error)->
		ﬁ.log.error error, config
		callback.call request, error, 500

	# send content if available
	if (method is 'PUT' or method is 'POST') and not ﬁ.util.isUndefined(config.body)
		if not ﬁ.util.isDictionary config.body
			throw new ﬁ.error 'Expecting JSON body.'
		config.body = JSON.stringify config.body
		request.write config.body

	request.end()



Yapp =
	get : (path, config, callback)->
		connect.call Yapp, path, config, callback, 'GET'
	put : (path, config, callback)->
		connect.call Yapp, path, config, callback, 'PUT'
	post : (path, config, callback)->
		connect.call Yapp, path, config, callback, 'POST'
	delete : (path, config, callback)->
		connect.call Yapp, path, config, callback, 'DELETE'

module.exports = Yapp
