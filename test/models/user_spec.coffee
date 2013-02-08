mongoose = require 'mongoose'
User = require '../../models/User'

require 'should'

describe 'User', ->

	user = {}

	before (done) ->
		mongoose.connect 'mongodb://localhost/rango-test', ->
			User.remove done

	beforeEach (done) ->
		# Create a new and clean user each time
		user = new User(
				first_name: 'Braulio'
				last_name: 'Chavez'
				fb_id: "12345678"
				friends: []
				created_at: Date.now()
				updated_at: Date.now()
			)
		done()

	it 'should have the right structure', (done) ->
		user.should.have.property('first_name')
		user.should.have.property('last_name')
		user.should.have.property('fb_id')
		user.should.have.property('friends')
		user.should.have.property('created_at')
		user.should.have.property('updated_at')
		done()

	it 'should save a new user', (done) ->
		user.save ->
			User.findOne _id: user._id, (err, retrievedUser) ->
				retrievedUser.first_name.should.eql "Braulio"
				retrievedUser.last_name.should.eql "Chavez"
				retrievedUser.fb_id.should.eql "12345678"
				done()