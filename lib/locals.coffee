Underscore = require 'underscore'

module.exports = (request, response)->

	_      : Underscore
	Config : Config

	pretty : not Config.live

	root   : '' #Config.url
	slogan : 'Yapp, tu centro comercial móvil.'
