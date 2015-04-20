(->
	__empty = (o)-> return false for k,v of o when o.hasOwnProperty k; return true;
	exports = {}
	module  = exports: {}
	`{{}}`
	return module.exports if module.exports.constructor isnt Object
	return exports if exports.constructor isnt Object
	return exports if __empty(module.exports)
	return module.exports
).call @
