

module.exports = (request, response)->
	return (status, data)->
		throw "Expecting an integer status, got: #{typeof status}" if not _.isNumber status
		data = null if not data
		response.writeHead status, 'Content-Type': 'application/json'
		response.end JSON.stringify
			success  : status is 200
			response : data
