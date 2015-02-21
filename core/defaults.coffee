Path = require 'path'
FS   = require 'fs'

fsmkdir = require('node-fs').mkdirSync

ext = '.defaults'

defaults = (parentPath)->
	parentPathRelative = parentPath.replace ﬁ.path.defaults, ''
	parentPath = Path.join ﬁ.path.defaults, parentPathRelative

	for nodeName in FS.readdirSync parentPath
		nodePath = Path.join(parentPath, nodeName)
		# is it a dir?
		if FS.statSync(nodePath).isDirectory()
			defaults Path.join(parentPath, nodeName)
			continue
		# Does it have the required extension?
		continue if Path.extname(nodePath) isnt ext
		# Does a file already exists in application?
		appPath = Path.join ﬁ.path.app, parentPathRelative
		appName = Path.join(appPath,nodeName).slice(0, -1 * ext.length)
		continue if FS.existsSync(appName)
		# does the containing directory exist? if not, create it recursively.
		fsmkdir(appPath, '0770', true) if not FS.existsSync(appPath)
		# Write file
		FS.writeFileSync appName, FS.readFileSync nodePath,'utf-8'
		ﬁ.log.trace "Written #{appName.replace(ﬁ.path.root,'')}"

defaults ﬁ.path.defaults