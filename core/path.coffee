# Node modules
Path = require 'path'
FS   = require 'fs'
OS   = require 'os'

path = {}

path.self = ﬁ.conf.core
path.root = ﬁ.conf.root

delete ﬁ.conf.core
delete ﬁ.conf.root

path.core      = Path.join path.self , 'core'
path.defaults  = Path.join path.core , 'defaults'

path.lib       = Path.join path.self , 'lib'
path.app       = Path.join path.root , 'app'
path.debug     = Path.join path.root , 'debug'
path.tmp       = Path.join OS.tmpDir(), ﬁ.conf.name

path.settings  = Path.join path.app , 'settings'
path.bundles   = Path.join path.app , 'bundles'
path.templates = Path.join path.app , 'master'
path.static    = Path.join path.app , 'static'

# make sure every path defined here exists
for name,dir of path
	try
		FS.mkdirSync(dir, '0700') if not FS.existsSync dir
	catch e
		throw new ﬁ.error e.message

module.exports = path
