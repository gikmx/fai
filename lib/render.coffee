Path = require 'path'
FS   = require 'fs'

_ = require 'underscore'

Log      = Config.require 'log'
Controls = Config.require 'controls'


module.exports = (name) ->

	view     = Path.join Config.path.views, name
	template = Path.join Config.path.views, 'template', 'render'

	assets =
		css : []
		js  : []

	parts = []

	for part in name.split '/'
		parts.push part
		part = parts.join '/'

		if FS.existsSync Path.join(Config.path.assets, 'static/css', part) + '.styl'
			assets.css.push part

		if FS.existsSync Path.join(Config.path.assets, 'static/js', part) + '.coffee'
			assets.js.push part

	renderer = (request, response, locals)->

		locals = {} if not Config.isRealObject locals

		exports = false
		if Config.isRealObject locals.exports
			exports =  locals.exports
			locals.exports = undefined

		request.app.locals.flash = undefined

		if Config.isRealObject request.session.flash
			Log.warn '¡FLASH! ' + request.session.uuid, request.session.flash
			request.app.locals.flash = request.session.flash
			request.session.flash = undefined

		Log.debug "Rendering: #{view}"

		response.render view, locals, (error, body)->
			throw new Config.error error if error

			request.app.locals.flash = undefined

			response.render template,
				body    : body
				name    : name
				css     : css
				js      : js
				assets  : assets
				exports : exports


	control = null

	parts = name.split '/'

	control = Controls[parts.shift()]
	if control
		for part in parts
			control = control[parts]
			break if not control


	if not control
		Log.warn "No control defined for #{name}."
		return renderer

	Log.debug "Found control for #{name}"
	return (request, response)->
		control.call {}, request, response, renderer
