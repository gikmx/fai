# Node modules
Path   = require 'path'
FS     = require 'fs'

# make sure the path exists
ﬁ.path.api = Path.join ﬁ.path.app, 'api'
FS.mkdirSync(ﬁ.path.api, '0700') if not FS.existsSync ﬁ.path.api

# determine base path for API calls
ﬁ.conf.api = '/api' if not ﬁ.util.isString ﬁ.conf.api

Request  = require './request'
Traverse = require './traverse'

# Parse every control defined on the api folder
Traverse(ﬁ.requireFS ﬁ.path.api)

ﬁ.api =
	get    :-> Request.apply Request, ['get'].concat Array::slice.call arguments
	put    :-> Request.apply Request, ['put'].concat Array::slice.call arguments
	post   :-> Request.apply Request, ['post'].concat Array::slice.call arguments
	delete :-> Request.apply Request, ['delete'].concat Array::slice.call arguments