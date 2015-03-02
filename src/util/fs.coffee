module.exports =

	dirRemove: (path) ->
		try
			files = FS.readdirSync(path)
		catch e
			throw new ﬁ.error e.message
		if files.length > 0
			i = 0
			while i < files.length
				file = path + '/' + files[i]
				if FS.statSync(file).isFile()
					FS.unlinkSync file
				else
					rmRf file
				i++
		FS.rmdirSync path

	# traverse recursively
	dirwalk: (path, callback, isRecursive)->
		throw new ﬁ.error('Expecting callback.') if not util.isFunction callback
		path = String path
		if not FS.existsSync path or not FS.statSync(path).isDirectory()
			throw new ﬁ.error 'Invalid directory.'
		callback.call(null, path) if not isRecursive
		for node in FS.readdirSync path
			node = Path.join path, node
			continue if not FS.statSync(node).isDirectory()
			callback.call null, node
			util.dirwalk node, callback, true