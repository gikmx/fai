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
	ﬁ.log.trace "Control: #{name}."

	# if no view is found, return control only
	view = (Path.join ﬁ.path.views, name) + '.jade'
	if not FS.existsSync view
		ﬁ.log.warn "No view for #{name}."
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
			ﬁ.log.trace "Style: #{name}."
		if FS.existsSync Path.join(ﬁ.path.assets_js,part) + ﬁ.conf.ext
			assets.js.push part
			ﬁ.log.trace "Script: #{name}."

	return (request, response, next)->
		render = response.render
		response.render = (locals)->

			locals = {} if not ﬁ.util.isDictionary(locals)
			locals = ﬁ.util.extend {}, ﬁ.locals, locals

			render.call response, view, locals, (error, content)->
				throw new ﬁ.error error.message if error
				ﬁ.log.trace "View: #{name}."
				render.call response, template.render,
					css     : ﬁ.locals.css
					js      : ﬁ.locals.js
					content : content
					assets  : assets

		control.call ﬁ.server, request, response, next


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
	ﬁ.log.trace "#{method.toUpperCase()} #{route}"

module.exports =
	get    : -> render.apply this, ['get'].concat Array::slice.call arguments
	post   : -> render.apply this, ['post'].concat Array::slice.call arguments
	put    : -> render.apply this, ['put'].concat Array::slice.call arguments
	delete : -> render.apply this, ['delete'].concat Array::slice.call arguments
