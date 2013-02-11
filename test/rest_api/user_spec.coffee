require 'should'
http = require('http')

describe 'Rest-API for User', ->

	# Override this object to specify the options for each case
	default_options = {}


	# Call this function to make any http request
	# options define the method, host, port and path
	# the callback will receive the json_object and responde returned by the server
	# the done function is used in the error callback
	make_request = (options, callback, done) ->
		req = http.request(
			options
			(res) ->
				res.setEncoding('utf8')

				raw_data = ""

				res.on('data', (chunk) ->
					raw_data += chunk
				)

				res.on('end', () ->
					json_data = JSON.parse(raw_data)
					callback(json_data, res)
				)
		)
		req.on('error', (e) ->
			done(e)
		)
		req.end()

	beforeEach (done) ->
		# Reset Default options
		default_options =
			method: 'GET'
			hostname: "127.0.0.1"
			port: 3000
			path: '/'

		done()

	it 'should GET a list of Users', (done) ->
		default_options.path = '/users.json'
		cb = (json_data, res)->
			res.statusCode.should.be.equal(200)
			json_data.should.be.instanceof(Array)
			done()
		make_request(default_options, cb, done)

	it 'should GET one specific User', (done) ->
		fb_id = '12345678'
		default_options.path = "/users/#{fb_id}.json"
		cb = (json_data, res) ->
			res.statusCode.should.be.equal(200)
			json_data.should.have.property('first_name')
			json_data.first_name.should.be.eql("Braulio")
			done()
		make_request(default_options, cb, done)