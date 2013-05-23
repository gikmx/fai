# Node modules
Path = require 'path'
FS   = require 'fs'

path = {}

path.self       = FS.realpathSync __dirname + '/..'
path.root       = Path.dirname path.self
path.core       = Path.join path.self     , 'core'
path.lib        = Path.join path.self     , 'lib'
path.app        = Path.join path.root     , 'app'
path.settings   = Path.join path.app      , 'settings'
path.frontend   = Path.join path.app      , 'frontend'
path.backend    = Path.join path.app      , 'backend'
path.controls   = Path.join path.backend  , 'controls'
path.views      = Path.join path.backend  , 'views'
path.static     = Path.join path.frontend , 'static'
path.assets     = Path.join path.frontend , 'assets'
path.assets_css = Path.join path.assets   , 'css'
path.assets_js  = Path.join path.assets   , 'js'

# make sure every path defined here exists
for name,dir of path
	try
		FS.mkdirSync(dir, '0700') if not FS.existsSync dir
	catch e
		throw new ﬁ.error e.message

module.exports = path
