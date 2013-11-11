OS = require 'os'
IP = null

for name, ifaces of OS.networkInterfaces()
	for iface in ifaces
		IP = iface.address if iface.family is 'IPv4' and not iface.internal

return (module.exports = false) if ﬁ.conf.live or not IP

module.exports = "//#{IP}:8888/target/target-script-min.js"