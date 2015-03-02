util = {}

util.bytes = (bytes)->
	sz = ['B', 'KB', 'MB', 'GB','TB']
	return 0 if not bytes
	i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
	return Math.round(bytes / Math.pow(1024, i), 2) + sz[i]

# Convert a number into a comma friendly string.
util.addCommas = (str)->
	str = String(str).replace /\B(?=(\d{3})+(?!\d))/g, ','
	return str

module.exports = util