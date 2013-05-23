# Node modules
FS = require 'fs'

settings = {}

settings[name] = setting for name,setting of ﬁ.requireFS ﬁ.path.settings

for name, cont of ﬁ.util.getDirContent ﬁ.path.core + '/settings', '.setting'
	path = "#{ﬁ.path.settings}/#{name}#{ﬁ.conf.ext}"
	continue if FS.existsSync path
	ﬁ.log.trace "Created #{name} setting, from template."
	FS.writeFileSync path, cont

if not ﬁ.util.isDictionary settings.app
	throw new ﬁ.error 'The application settings file is missing.'

if not ﬁ.util.isString settings.app.secret
	throw new ﬁ.error 'A secret phrase must be defined in application settings.'

module.exports = settings
