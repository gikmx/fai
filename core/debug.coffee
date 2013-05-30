FS   = require 'fs'
Path = require 'path'

write = undefined
memer = undefined
times = -1

FS.unlinkSync Path.join(ﬁ.path.debug,file) for file in FS.readdirSync ﬁ.path.debug
FS.rmdirSync ﬁ.path.debug

if not ﬁ.conf.debug
	module.exports = ->
	return

FS.mkdirSync ﬁ.path.debug

try
	{write} = require Path.join(ﬁ.path.lib, 'debug')
	memer   = require 'memwatch'
catch e
	throw ﬁ.error 'Debug modules are not available.'

memer.on 'leak', (info)->
	infos = []
	infos.push "#{k}:\t#{v}" for k,v of info
	ﬁ.log.custom (method:'error', caller:'LEAK'), "\n\t" + infos.join '\n\t'

memer.on 'stats', (info)->
	infos = []
	hasBytes = ['estimated_base','current_base','min','max']
	for k,v of info
		v = if hasBytes.indexOf(k) isnt -1 then ﬁ.util.bytes(v) else v
		infos.push "#{k}:#{v}"
	ﬁ.log.custom (method:'debug', caller:'STATS'), infos.join ' '

pad = (num, pos) ->
	num = parseInt num
	pos = parseInt pos
	return (Array(pos).join('0') + num).substr(pos * -1)

debug = (name)->
	return if ﬁ.conf.live
	times++
	name = if typeof name is 'string' then pad(times, 5) + "-" + name else pad(times, 5)
	write ﬁ.path.debug, name
	return undefined

debug('init')

module.exports = debug
