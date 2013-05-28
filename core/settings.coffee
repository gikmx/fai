# Node modules
Path = require 'path'
FS   = require 'fs'

settings = {}

settings[name] = setting for name,setting of ﬁ.requireFS ﬁ.path.settings

if not ﬁ.util.isDictionary settings.app
	throw new ﬁ.error 'The application settings file is missing.'

if not ﬁ.util.isString settings.app.secret
	throw new ﬁ.error 'A secret phrase must be defined in application settings.'

module.exports = settings
