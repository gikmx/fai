# Node modules
Path = require 'path'
FS   = require 'fs'
OS   = require 'os'

path = {}

path.core         = {}
path.core.root    = __dirname
path.core.util    = Path.join path.core.root, 'util'
path.core.bundles = Path.join path.core.root, 'bundles'
path.core.ext     = Path.extname __filename

path.root = FS.realpathSync "#{path.core.root}/.."
path.tmp  = Path.join do OS.tmpDir, "fi.#{ﬁ.conf.name}"

path.script      = {}
path.script.root = Path.dirname  process.argv[1]
path.script.ext  = Path.extname  process.argv[1]
path.script.name = Path.basename process.argv[1], path.script.ext

path.app         = {}
path.app.root    = Path.join path.script.root , 'app'
path.app.conf    = Path.join path.app.root    , 'conf'
path.app.bundles = Path.join path.app.root    , 'bundles'
path.app.master  = Path.join path.app.root    , 'master'
path.app.static  = Path.join path.app.root    , 'static'

# make sure every path defined here exists
try
	FS.mkdirSync(path.tmp) if not FS.existsSync path.tmp
	for name,dir of path.app
		continue if FS.existsSync dir
		FS.mkdirSync(dir, '0755') if not FS.existsSync dir
catch e
	process.stdout.write "\n#{e.message}\n"
	process.exit 1

module.exports = path