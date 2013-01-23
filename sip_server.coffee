sip = require("sip")
sys = require("sys")
redis = require("redis")

exports.start = () ->

	trim = (str) ->
		str.replace /^\s+|\s+$/g, ""

	sip.start {}, (request) ->
		console.log("STARTED")
		try
			address = sip.parseUri(request.headers.to.uri)
			sys.puts "host: " + address.host
			siphost = address.host
			client = redis.createClient()
			sys.puts trim(request.method) + " received."

			# Handle SIP Registrations
			if trim(request.method) is "REGISTER"
				contact = request.headers.contact
				console.log(JSON.stringify(contact, null, 2))
				if Array.isArray(contact) and contact.length and (+(contact[0].params.expires or request.headers.expires or 300)) > 0
					sys.puts "Registering user " + request.headers.to.name + " at " + contact[0].uri
					client.set address.user, contact[0].uri
				else
					sys.puts "Logging off user " + request.headers.to.name
					client.del address.user

				# Build the response
				response = sip.makeResponse(request, 200, "OK")

				# Send the response to the SIP client
				sip.send response

			# Handle SIP Invites
			if trim(request.method) is "INVITE"
				sip.send sip.makeResponse(request, 100, "Trying")

				# Look up the registration info, for the user being
				# called.
				address = sip.parseUri(request.uri)
				sys.puts "host: " + address.host

				if address.host is "127.0.0.1"	# Our Registrar
					client.get address.user, (err, contact) ->
						if err or contact is null
							sys.puts "Redirecting call to " + address.user
							response = sip.makeResponse(request, 302, "Moved Temporarily")
							response.headers.contact = [ uri: "sip:194@sip.teleku.com" ]
							sip.send response
						else
							sys.puts "User " + address.user + " is found at " + contact
							sys.puts "contact " + contact
							response = sip.makeResponse(request, 302, "Moved Temporarily")
							response.headers.contact = [ uri: contact ]
							sip.send response
					# Close Redis Client
					client.quit()
				else	# Host other than our registrar
					sys.puts "Routing call to " + request.uri
					response = sip.makeResponse(request, 180, "Ringing")
					sip.send response
		# Handle exceptions
		catch e
			sip.send sip.makeResponse(request, 500, "Internal Server Error")
			sys.debug "Exception " + e + " at " + e.stack

