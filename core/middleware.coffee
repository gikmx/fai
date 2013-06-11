Colors = require 'colors'

middleware = ->

	middleware.all = [] if not middleware.all

	for ware in Array::slice.call arguments
		throw ﬁ.error 'Expecting a middleware function.' if not ﬁ.util.isFunction ware
		middleware.all.push ware
		f = ware.toString()
			.replace(/^[^\{]+\{/,'')
			.replace(/\s+/g,' ')
			.substring(0, 50)

		ﬁ.log.trace Colors.grey("\"#{f}… \"")

module.exports = middleware
