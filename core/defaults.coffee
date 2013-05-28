Path = require 'path'
FS   = require 'fs'

map =
	frontend: '.jade'

dirs = []
for dir in FS.readdirSync ﬁ.path.core_defaults
	path = Path.join(ﬁ.path.core_defaults, dir)
	continue if not FS.statSync(path).isDirectory()
	ext = if map[dir] then map[dir] else ﬁ.conf.ext
	for name, contents of ﬁ.util.getDirContent path, '.defaults'
		path = Path.join ﬁ.path[dir], "#{name}#{ext}"
		continue if FS.existsSync path
		FS.writeFileSync path, contents
		ﬁ.log.trace "Created #{dir}/#{name} from defaults."
