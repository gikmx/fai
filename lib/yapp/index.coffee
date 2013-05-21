HTTPS = require 'https'

_ = require 'underscore'

Log = Config.require 'log'

connect = (path, config, callback, method)->
	config   = {} if not Config.isRealObject config

	throw new Config.error 'Expecting callback.' if not _.isFunction callback

	yConf = Config.yapp

	# Populate config, base upon global environment config
	_.each yConf, (val, key)->
		if Config.isRealObject val
			config[key] = _.extend {}, val, config[key]
		else
			return if not _.isUndefined config[key]
			config[key] = val

	config.path    = yConf.path + String(path)
	config.method  = method
	config.agent   = new HTTPS.Agent config

	info = "[#{config.method}] #{config.path}"

	Log.debug 'CONFIG:', config

	request = HTTPS.request config,
		(response)->
			response.setEncoding 'utf-8'
			data = ''

			response.on 'data', (chunk)->
				data += chunk

			response.on 'end', ()->
				res = null
				try
					res = JSON.parse data
				catch e
					Log.warn "#{info} #{response.statusCode} JSON.parse: ", data, e
					res = response: data
				Log.debug "#{info} #{response.statusCode}", res
				if response.statusCode is 200
					callback.call null, null, response.statusCode, res
				else
					callback.call null, res, response.statusCode

	request.on 'error', (error)->
		Log.error error, config
	 callback.call request, error, 500

	 send content if available
	if (method is 'PUT' or method is 'POST') and not _.isUndefined(config.body)
		if not Config.isRealObject config.body
			throw new Config.error 'Expecting JSON body.'
		config.body = JSON.stringify config.body
		request.write config.body

	request.end()
	Log.trace 'Requested', config


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
