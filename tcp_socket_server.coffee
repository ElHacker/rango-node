net = require('net')
util = require('util')

# Keep track of the socket clients
clients = []

# Returns the other socket connected
theOtherSocket = (sender) ->
	otherSocket = {}
	for client in clients
		otherSocket = client unless client == sender
	otherSocket

module.exports =
	# starts a TCP server
	createServer : ()->
		tcp_server = net.createServer(
			(socket) ->
				console.log("TCP SERVER CONNECTED: ")

				# Identify this client
				socket.name = "papito"

				# put this client on the list
				clients.push(socket)

				# socket.write 'Wellcome ' + socket.name + "\r\n"
				
				socket.on 'data', (data)->
					console.log(data)
					if clients.length > 1
						flushed = theOtherSocket(socket).write(data)
						# Pause the socket stream when the write stream gets saturated
						socket.pause() unless flushed

				socket.on 'drain', ()->
					if clients.length > 1
						# Resume the socket stream when the write stream gets hungry
						theOtherSocket(socket).resume()


				# Remove client from the list when it leaves
				socket.on 'end', ()->
					clients.splice(clients.indexOf(socket), 1)
					console.log(socket.name + " left the chat\r\n")
				

		).listen(2500, ()->	# 'listening' listener
			console.log("TCP SERVER BOUND")
		)
		tcp_server
