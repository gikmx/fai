# Note: Every identifier starting with an underscore will be replaced with
#       a randomly generated one.

# Using an auto instantiated class to somewhat obscure by scrambling
# where the methods and properties are going to be located.
class

	# This will be called on instantiation, but instead of returning the instance
	# it will return the parse method, binded with the instance.
	constructor: ->
		@_full   = undefined # this will be replaced with the full key.
		@_length = undefined
		return @_unscramble()


	# This is the function that will be replacing all of encoded strings.
	_decode: (_str)->
		x = _str
			.split ''
			.map (c)=>
				return c if (i = @_code.indexOf c) is -1
				return @_base.charAt i
			.join('')
		debugger
		return x

	# This will set the code and base keys after extracting them from @_full
	_unscramble: ->
		_r = new Array (_raw = @_full.match new RegExp(".{1,#{@_length+1}}",'g')).length
		_raw.map (_chk)-> _r[_chk[_chk.length - 1].charCodeAt(0) - 48] = _chk.slice(0,-1)
		[@_base, @_code] = (
			_r = _r.join('').replace(new RegExp(String.fromCharCode(61),'g'),'')
		).match new RegExp(".{1,#{_r.length/2}}",'g')
		# return the decode method binded with the instance.
		return @_decode.bind @

###
# This is a utility method, it returns:
# 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
_base64 = ((c) ->
	c.splice(1,0,c[0].toUpperCase())
	r = []
	for _ in c
		i = _[0].charCodeAt 0
		f = _[1].charCodeAt 0
		r.push String.fromCharCode(i++) while i <= f
	r.join('') + unescape('+/%3D')
)(
	[[97,122],[48,57]].map (a)-> a.map((b)-> String.fromCharCode(b)).join('')
)
###