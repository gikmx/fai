# Node modules
Path   = require 'path'
FS     = require 'fs'

# make sure the path exists
ﬁ.path.api = Path.join ﬁ.path.app, 'api'
FS.mkdirSync(ﬁ.path.api, '0700') if not FS.existsSync ﬁ.path.api

# determine base path for API calls
ﬁ.conf.api = '/api' if not ﬁ.util.isString ﬁ.conf.api

Request = require './request'
Middle  = require './middleware'

# enabling routing for existing controls automatically
methods  = ['get','put','post','delete']
controls =
	'get'    : {}
	'put'    : {}
	'post'   : {}
	'delete' : {}

# Enable all API methods just after configuring
ﬁ.queueMid.push ->

	set = (method, control)->
		uri = Path.dirname control.replace(ﬁ.path.api, '').substring(1)
		err = "[#{method.toUpperCase()}] #{uri}"
		try
			control = require control
		catch e
			throw new ﬁ.error "#{err}: #{e.message}"

		throw new ﬁ.error "#{err}: Invalid controller." if not ﬁ.util.isFunction control
		url = Path.join(ﬁ.conf.api, uri)
		controls[method][uri] = control
		ﬁ.log.custom (method:'info', caller:"API] [#{method.toUpperCase()}"), "#{url}"

	ﬁ.util.dirwalk ﬁ.path.api, (path)->
		# is there a "catch all" file?
		if FS.existsSync(control = Path.join path, "all#{ﬁ.conf.ext}")
			return (set(method, control) for method in methods)
		for method in methods
			continue if not FS.existsSync(control = Path.join path, (method + ﬁ.conf.ext))
			set method, control

ﬁ.middleware.prepend 'fi-api', Middle(controls)

ﬁ.api =
	get    :-> Request.apply Request, ['get'].concat Array::slice.call arguments
	put    :-> Request.apply Request, ['put'].concat Array::slice.call arguments
	post   :-> Request.apply Request, ['post'].concat Array::slice.call arguments
	delete :-> Request.apply Request, ['delete'].concat Array::slice.call arguments
