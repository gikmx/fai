Path = require 'path'
FS   = require 'fs'

Assets = ﬁ.require 'core', Path.join 'bundles','assets'

Template =
	master : {}
	render : {}

Bundle = {}

# walk in every directory inside bundles
ﬁ.util.dirwalk ﬁ.path.bundles, (path)->

	# determine if there are controls and views available
	uri  = path.replace(ﬁ.path.bundles, '').substring(1)
	ctrl = Path.join path, 'control' + ﬁ.conf.ext
	ctrl = if FS.existsSync(ctrl) then ctrl else false
	view = Path.join path, 'view.jade'
	view = if FS.existsSync(view) then view else false
	styl = Path.join path, 'view.styl'
	styl = if FS.existsSync(styl) then styl else false
	jqry = Path.join path, 'view.coffee'
	jqry = if FS.existsSync(jqry) then jqry else false

	# make assets available if existent
	Assets.store path, 'view' if styl or jqry

	return if not ctrl and not view

	# Keep a record of what do we have.
	Bundle[uri] = ctrl: ctrl, view: view


# Ready assets in templates to be consumed
for node in FS.readdirSync ﬁ.path.templates
	continue if Path.extname(node) isnt '.jade'
	Assets.store ﬁ.path.templates, Path.basename(node, '.jade'), 'templates'

# Jade does not support dynamic includes, so we have to create a
# hidden template that'll establish the format of every view with their assets.
# The template will be read from core, dynamically modified and stored in a temp dir.
Template.render.path = Path.join ﬁ.path.core, 'bundles', 'template.jade'
throw new ﬁ.error 'Missing rendering template.' if not FS.existsSync Template.render.path
Template.render.cont = FS.readFileSync Template.render.path, 'utf-8'
# Temporal path, relative to templates path, we'll replace it in render template.
Template.render.cont = Template.render.cont.replace '#{template}',
	Path.join Path.relative(ﬁ.path.tmp, ﬁ.path.templates), 'master'
Template.render.path = Path.join ﬁ.path.tmp, "fi-render.jade"
try
	FS.writeFileSync Template.render.path, Template.render.cont
	delete Template.render.cont
catch e
	throw new ﬁ.error "Couldn't write render template: #{e.message}"
ﬁ.log.warn Template.render.path

module.exports = (name)->

	renderview = (render, response)-> return

	# Does a controller exists with specified name?
	throw new ﬁ.error "Bundle #{name} was not found." if not Bundle[name]

	ctrl = null
	view = null

	# If a controller doesn't exist, simulate a controller that just renders the view.
	if not Bundle[name].ctrl
		ctrl = (request, response)-> response.render()
	else
		ctrl = require Bundle[name].ctrl

	view = Bundle[name].view

	return (request, response, next)->

		# store original render
		fnRender = response.render

		response.renderview = ->

			args = Array.prototype.slice.call arguments

			path = if ﬁ.util.isString args[0] then args.shift() else view

			throw new ﬁ.error 'A view is not available.' if not path

			vars = if ﬁ.util.isDictionary args[0] then args.shift() else {}
			back =  if ﬁ.util.isFunction args[0] then args.shift() else undefined

			path = Path.resolve Path.dirname(view), path

			locals = {}
			locals[k] = v for k,v of ﬁ.locals
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
			locals[k] = v for k,v of ﬁ.locals
			locals[k] = v for k,v of assetsLocals
			locals[k] = v for k,v of (if not ﬁ.util.isDictionary(vars) then {} else vars)

			fnRender.call response, path, locals, (error, content)->
				throw new ﬁ.error error.message if error

				locals[k] = v for k,v of ﬁ.locals
				locals[k] = v for k,v of assetsLocals

				locals.content = content
				locals.assets  = assetsRoutes

				fnRender.call response, Template.render.path, locals

				locals = assetsLocals = assetsRoutes = errro = content = undefined

		ctrl.call ﬁ.server, request, response, next
