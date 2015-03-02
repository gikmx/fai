UUID       = require 'node-uuid'

module.exports =

	uuid: UUID.v4

	hmac: (str, type)->
		type = 'base64' if not util.isString(type)
		if not util.isDictionary(ﬁ.app.conf.app) or not util.isString(ﬁ.app.conf.app.secret)
			throw new ﬁ.error 'Missing app secret setting.'
		hmac = Crypto.createHmac('sha1', ﬁ.app.conf.app.secret)
		return hmac.update(str).digest(type)

	# convert a string into an url friendly slug.
	toSlug: (str)->
		from = 'ãàáäâẽèéëêìíïîõòóöôùúüûñç·/_,:;'
		to   = 'aaaaaeeeeeiiiiooooouuuunc------'

		str = String(str).replace(/^\s+|\s+$/g, '').toLowerCase()
		str = str.replace new RegExp(char,'g'), (to.charAt(i) for char,i in from)
		str = str
			.replace(/[^a-z0-9 -]/g, '')
			.replace(/\s+/g,'-')
			.replace(/-+/g,'-')
		return str

	id: ->
		text = ''
		possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
		i = 0
		while i < 8
			text += possible.charAt(Math.floor(Math.random() * possible.length))
			i++
		return text
