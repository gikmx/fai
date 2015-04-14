Path = require 'path'
FS   = require 'fs'

Assets = ﬁ.require 'core.bundles', 'assets'

Template =
	master : {}
	render : {}

Bundle = {}

# walk in every directory inside bundles
ﬁ.util.fs.dirwalk ﬁ.path.app.bundles, (path)->

	# determine if there are controls and views available
	ext   = ﬁ.path.script.ext
	files = ["control#{ext}", 'view.jade', 'view.styl', "view#{ext}"]
	for file,i in files
		file     = Path.join path, file
		files[i] = if FS.existsSync file then file else false
	[ctrl, view, styl, script] = files

	# make assets available if existent
	Assets.store path, 'view' if styl or script

	return if not ctrl and not view

	# Keep a record of what do we have.
	uri         = path.replace(ﬁ.path.app.bundles, '').substring(1)
	Bundle[uri] = ctrl: ctrl, view: view


# Ready assets in templates to be consumed
for node in FS.readdirSync ﬁ.path.app.master
	continue if Path.extname(node) isnt '.jade'
	Assets.store ﬁ.path.app.master, Path.basename(node, '.jade'), 'app.master'

# Jade does not support dynamic includes, so we have to create a
# hidden template that'll establish the format of every view with their assets.
# The template will be read from core, dynamically modified and stored in a temp dir.
Template.render.path = Path.join ﬁ.path.core.bundles, 'template.jade'
console.info Template.render.path
throw new ﬁ.error 'Missing rendering template.' if not FS.existsSync Template.render.path
Template.render.cont = FS.readFileSync Template.render.path, ﬁ.conf.charset
# Temporal path, relative to templates path, we'll replace it in render template.
if not FS.existsSync Path.join(ﬁ.path.app.master, 'view.jade')
	throw new ﬁ.error 'The master view is missing or invalid.'
Template.render.cont = Template.render.cont.replace '#' + '{template}',
	Path.join Path.relative(ﬁ.path.tmp, ﬁ.path.app.master), 'view'
Template.render.path = Path.join ﬁ.path.tmp, 'fi-render.jade'
try
	FS.writeFileSync Template.render.path, Template.render.cont
	delete Template.render.cont
catch e
	throw new ﬁ.error "Couldn't write render template: #{e.message}"
ﬁ.log.debug Template.render.path

module.exports = (name)->

	renderview = (render, response)-> return

	# Does a controller exists with specified name?
	throw new ﬁ.error "Bundle '#{name}' was not found." if not Bundle[name]

	ctrl = null
	view = null
	# If a controller doesn't exist, simulate a controller that just renders the view.
	if not Bundle[name].ctrl
		ctrl = (request, response)-> response.render()
	else
		ctrl = require Bundle[name].ctrl
		throw new ﬂ.error "Bundle '#{name}' is invalid." if not ﬁ.util.isFunction ctrl
	view = Bundle[name].view

	return (request, response, next)->

		# store original render
		fnRender = response.render

		request.bundle = ->
			method = request.method.toLowerCase()
			return false if not ﬁ.routes[request.url] or not ﬁ.routes[request.url][method]
			return ﬁ.routes[request.url][method]

		response.renderview = ->

			args = Array.prototype.slice.call arguments

			path = if ﬁ.util.isString args[0] then args.shift() else view

			throw new ﬁ.error 'A view is not available.' if not path

			vars = if ﬁ.util.object.isDict args[0] then args.shift() else {}
			back = if ﬁ.util.isFunction args[0] then args.shift() else undefined

			path = Path.resolve Path.dirname(view), path

			locals = {}
			locals[k] = v for k,v of ﬁ.app.locals
			locals[k] = v for k,v of Assets.locals(name)
			locals[k] = v for k,v of vars

			fnRender.call response, path, locals, back

		response.render = ->
			# Expose assets methods, already defined locals, and custom locals.
			assetsLocals = Assets.locals(name)
			assetsRoutes = Assets.tree(name)

			args = Array::slice.call arguments

			path = if ﬁ.util.isString args[0] then args.shift() else view

			throw new ﬁ.error 'A view is not available.' if not path

			path = Path.resolve Path.dirname(view), path

			vars = args.shift()

			locals    = {}
			locals[k] = v for k,v of ﬁ.app.locals
			locals[k] = v for k,v of assetsLocals
			locals[k] = v for k,v of (if not ﬁ.util.object.isDict(vars) then {} else vars)

			onFnRender = (error, content)->
				throw error if error

				locals[k] = v for k,v of ﬁ.locals
				locals[k] = v for k,v of assetsLocals

				locals.content = content
				locals.assets  = assetsRoutes

				fnRender.call response, Template.render.path, locals

				locals = assetsLocals = assetsRoutes = error = content = undefined

			fnRender.call response, path, locals, onFnRender

		ctrl.call ﬁ.server, request, response, next

