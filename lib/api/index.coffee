# Node modules
Path   = require 'path'
FS     = require 'fs'

# make sure the path exists
ﬁ.path.api = Path.join ﬁ.path.app, 'api'
FS.mkdirSync(ﬁ.path.api, '0700') if not FS.existsSync ﬁ.path.api

# determine base path for API calls
ﬁ.conf.api = '/api' if not ﬁ.util.isString ﬁ.conf.api

Request = require './request'
Handler = require './handler'

methods = ['get','put','post','delete','all']

ﬁ.util.dirwalk ﬁ.path.api, (path)->
	uri = path.replace(ﬁ.path.api, '').substring(1)

	for method in methods
		control = Path.join path, method + ﬁ.conf.ext
		continue if not FS.existsSync control
		try
			control = require control
		catch e
			throw new ﬁ.error "[#{method.toUpperCase()}] #{uri}: #{e.message}"

		throw new ﬁ.error "Invalid controller: #{uri}" if not ﬁ.util.isFunction control
		url = Path.join(ﬁ.conf.api, uri)
		ﬁ.server[method] url, Handler(control)
		ﬁ.log.custom (method:'info', caller:"API:#{method.toUpperCase()}"), "#{url}"

ﬁ.api =
	get    :-> Request.apply Request, ['get'].concat Array::slice.call arguments
	put    :-> Request.apply Request, ['put'].concat Array::slice.call arguments
	post   :-> Request.apply Request, ['post'].concat Array::slice.call arguments
	delete :-> Request.apply Request, ['delete'].concat Array::slice.call arguments