Crypto = require 'crypto'


module.exports = class

	encrypt = (string, secret, type)->
		Crypto.createHmac('sha1', secret).update(string).digest(type)

	constructor: (@string, @secret=ﬁ.settings.app.secret, @type='base64')->
		@hash  = encrypt @string, @secret, @type

	challenge: (hash)-> @hash is hash