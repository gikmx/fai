Path = require 'path'
FS   = require 'fs'
OS   = require 'os'

Routes   = {}
template = {}

path = Path.join ﬁ.path.views, 'template'

template.root = Path.join path,'template.jade'
throw new ﬁ.error "Missing template." if not FS.existsSync template.root

# This horrible hack exists, because Jade does not support dynamic includes
template.render = Path.join ﬁ.path.core_templates, 'render.jade'
throw new ﬁ.error "Missing Render template." if not FS.existsSync template.render
cont = FS.readFileSync template.render, 'utf-8'
path = Path.join Path.relative(OS.tmpDir(), path), 'template'
cont = cont.replace '#{template}', path
template.render = Path.join OS.tmpDir(), 'render.jade'
try
	FS.writeFileSync template.render, cont
catch e
	throw new ﬁ.error e.message
ﬁ.log.warn 'Saved render template into tmpdir, due to ugly bug.'

auto = (name)->
	# Get control name from path
	control = ﬁ.controls
	for part in name.split Path.sep
		control = control[part]
		continue if not ﬁ.util.isUndefined control
		control = false
		break
	if not ﬁ.util.isFunction control
		throw new ﬁ.error "Expecting a control function for #{name}."
	ﬁ.log.trace "Loaded #{name} control."

	# if no view is found, return control only
	view = (Path.join ﬁ.path.views, name) + '.jade'
	if not FS.existsSync view
		ﬁ.log.warn "No view defined for #{name}."
		return control

	# View exists, check if there are assets related to it
	assets =
		css : []
		js  : []

	parts = []
	for part in name.split Path.sep
		parts.push part
		part = parts.join Path.sep
		if FS.existsSync Path.join(ﬁ.path.assets_css,part) + '.styl'
			assets.css.push part
			ﬁ.log.trace "Appended #{name} style asset."
		if FS.existsSync Path.join(ﬁ.path.assets_js,part) + ﬁ.conf.ext
			assets.js.push part
			ﬁ.log.trace "Appended #{name} script asset."

	return (request, response, next)->
		control.call ﬁ.server, request, response, ->
			response.render view, ﬁ.locals, (error, content)->
				throw new ﬁ.error error.message if error
				ﬁ.log.trace "Loaded #{name} view."
				response.render template.render, ﬁ.util.extend {}, ﬁ.locals,
					content : content
					assets  : assets


render = ->
	handles = Array::slice.call arguments
	method  = handles.shift()
	route   = handles.shift()

	throw new ﬁ.error 'Expecting a method.' if not ﬁ.util.isString method
	throw new ﬁ.error 'Expecting a route.' if not ﬁ.util.isString route
	throw new ﬁ.error 'Expecting at least one handle.' if handles.length < 1

	throw new ﬁ.error 'Invalid method.' if not ﬁ.util.isFunction ﬁ.server[method]
	throw new ﬁ.error 'Invalid route.' if route[0] isnt '/'

	controls = []

	# convert each remaining argument
	for handle in handles
		handle = auto(handle) if ﬁ.util.isString handle
		throw new ﬁ.error 'Invalid handle.' if not ﬁ.util.isFunction handle
		controls.push handle

	controls.unshift(route)
	ﬁ.server[method].apply ﬁ.server, controls
	ﬁ.log.trace "Route: #{method.toUpperCase()} #{route}"

module.exports =
	get    : -> render.apply this, ['get'].concat Array::slice.call arguments
	post   : -> render.apply this, ['post'].concat Array::slice.call arguments
	put    : -> render.apply this, ['put'].concat Array::slice.call arguments
	delete : -> render.apply this, ['delete'].concat Array::slice.call arguments
