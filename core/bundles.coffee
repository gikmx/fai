OS   = require 'os'
Path = require 'path'
FS   = require 'fs'

ext = '.jade'

master = {}
render = {}

Controls = ﬁ.requireFS ﬁ.path.controls

master.path = Path.join ﬁ.path.templates, "master#{ext}"
throw new ﬁ.error 'Missing master template.' if not FS.existsSync master.path

# Jade does not support dynamic includes, so we have to create a 
# hidden template that'll establish the format of every view with their assets.
# The template will be read from core, dynamically modified and stored in a temp dir.

render.path = Path.join ﬁ.path.core_templates, "render#{ext}"
throw new ﬁ.error 'Missing rendering template.' if not FS.existsSync render.path

# make temporal path, relative to templates path, and replace it from render template
render.tempath = Path.join Path.relative(OS.tmpDir(), ﬁ.path.templates), 'master'
render.content = FS.readFileSync render.path, 'utf-8'
render.content = render.content.replace '#{template}', render.tempath
render.path    = Path.join OS.tmpDir(), "fi-render#{ext}"
try
	FS.writeFileSync render.path, render.content
	delete render.content
catch e
	throw new ﬁ.error "Couldn't write render template on #{render.path} : #{e.message}"
ﬁ.log.warn "#{render.path}"

module.exports = (name)->
	# Does a controller exist with that name?
	control = Controls
	for part in name.split Path.sep
		control = control[part]
		continue if not ﬁ.util.isUndefined control
		control = false
		break
	
	view = Path.join ﬁ.path.views, "#{name}#{ext}"
	view = false if not FS.existsSync view

	throw new ﬁ.error "Bundle #{name} was not found." if not control and not view

	assets = ﬁ.assets.has name

	ﬁ.log.trace "#{name} control." if control
	ﬁ.log.trace "#{name} view." if view
	for k,v of assets
		continue if not v.length
		ﬁ.log.trace "#{name} assets #{k}:", v.join '; ' 

	# If a controller doesn't exist, simulate a controller that just renders the view.
	if not control
		control = (request, response)-> response.render()

	return control if not view

	return (request, response, next)->
		fnRender = response.render
		response.render = (locals)->
			locals = {} if not ﬁ.util.isDictionary(locals)
			locals = ﬁ.util.extend {}, ﬁ.locals, locals

			fnRender.call response, view, locals, (error, content)->
				throw new ﬁ.error error.message if error
				fnRender.call response, render.path,
					css     : ﬁ.locals.css
					js      : ﬁ.locals.js
					content : content
					assets  : assets
		control.call ﬁ.server, request, response, next