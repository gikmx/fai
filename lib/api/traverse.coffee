# Node modules
Path = require 'path'

# Local modules
Handler = require './handler'

traverse = (controls, root)->
	root = ﬁ.conf.api + '/' if not root
	for name, control of controls
		path = Path.join(root, name)
		if ﬁ.util.isDictionary(control)
			traverse(control, path)
			continue
		if not ﬁ.util.isFunction control
			throw new ﬁ.error "Non-function API control: #{name}"
		control = new control
		methods = ['get','put','post','delete']
		for method,i in methods
			if ﬁ.util.isFunction(control[method])
				ﬁ.server[method] path, Handler(control[method])
				ﬁ.log.trace "#{method.toUpperCase()} #{path}"
			else
				methods.splice(methods.indexOf(method), 1)
		
		if not methods.length
			throw new ﬁ.error "Non-method API control: #{name}"
	control = root = path = method = methods = null

module.exports = traverse