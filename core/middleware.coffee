Colors = require 'colors'

middleware = ->

	middleware.all = [] if not middleware.all

	for ware in Array::slice.call arguments
		throw ﬁ.error 'Expecting a middleware function.' if not ﬁ.util.isFunction ware
		middleware.all.push ware
		f = ware.toString()
			.replace(/^[^\{]+\{/,'')
			.replace(/\s+/g,' ')
			.substring(0, 33)

		ﬁ.log.trace "Queued middleware.", Colors.grey("\"#{f}… \"")

module.exports = middleware
