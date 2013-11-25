Path = require 'path'

ﬁ.path["fi-extend"] = Path.join ﬁ.path.root, 'fi-extend'

module.exports = (library, context="fi-extend")->
	throw new ﬁ.error 'Invalid library.' if not ﬁ.util.isString library

	Library = ﬁ.require context, library 

	# If library does not exist, or is anything but a dictionary, create/overwrite it.
	if not ﬁ[library] or not ﬁ.util.isDictionary ﬁ[library]
		ﬁ.log.trace "Enabled '#{library}' extend."
		return ﬁ[library] = Library 

	# extend current library
	for key,val of Library
		ﬁ.log.trace "Setting '#{key}' on top of ﬁ.#{library}."
		ﬁ[library][key] = val 
	