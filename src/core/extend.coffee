Path = require 'path'

ﬁ.path.script.extend = Path.join(ﬁ.path.script.root, 'extend')

module.exports = (library, context='script.extend')->
	throw new ﬁ.error 'Invalid library.' if not ﬁ.util.isString library

	Library = ﬁ.require context, library

	# If library does not exist, or is anything but a dictionary, create/overwrite it.
	if not ﬁ[library] or not ﬁ.util.object.isDict ﬁ[library]
		ﬁ.log.trace "Enabled '#{library}' extend."
		return ﬁ[library] = Library

	# extend current library
	for key,val of Library
		ﬁ.log.trace "Setting '#{key}' on top of ﬁ.#{library}."
		ﬁ[library][key] = val
