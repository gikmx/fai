ascii = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
chars = "áéíóúüñabcdefghijklmnopqrstuvwxyzÁÉÍÓÚÜÑABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_$+"

module.exports = class

	length:4

	base: null
	code: null
	full: null

	constructor: ->
		@full = do @scramble

	generate: (length=5)->
		str  = ''
		for i in [0..length]
			str += ascii.charAt Math.floor(Math.random() * ascii.length)
		return str

	encode: (str)->
		str
			.split ''
			.map (char)=>
				return char if (index = @base.indexOf char) is -1
				return @code.charAt index
			.join ''

	scramble: ->
		@base = ﬁ.util.array.shuffle(chars.split '').join ''
		@code = ﬁ.util.array.shuffle(@base.split '').join ''

		orig  = @base + @code
		orig += Array(@length - (orig.length % @length) + 1).join('=')
		imax  = orig.length / @length
		full  = new Array(imax)
		rand  = []
		j     = 0
		for i in [0..orig.length]

			# Split array every Nth element
			if not (i % @length)
				# skip the 0 index
				if buffer
					# Generate a random number that's not already in the rand array
					# then convert it to an ascii character, append it to the buffer.
					# it will be used to unscramble the string.
					loop
						num = Math.floor(Math.random() * imax)
						break if rand.indexOf(num) is -1
					# push number to random array to maintain uniqueness
					rand.push num
					# put buffer in desired order
					full[num] = buffer + String.fromCharCode(48 + j++)
				buffer = ''

			# Populate buffer in every pass
			buffer += orig[i]

		return full.join('')
