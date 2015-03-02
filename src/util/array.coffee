Underscore = require 'underscore'

module.exports =

	unique: Underscore.uniq

	shuffle: (o) ->
		j = undefined
		x = undefined
		i = o.length
		while i
			j = Math.floor(Math.random() * i)
			x = o[--i]
			o[i] = o[j]
			o[j] = x
		return o