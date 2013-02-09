mongoose = require 'mongoose'
User = require '../../models/User'
ObjectId = mongoose.Schema.ObjectId

require 'should'

describe 'User', ->

	user = {}

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
		mongoose.connect 'mongodb://localhost/rango-test', ->
			User.remove done

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

	it "should retrieve the user's friends", (done) ->
		# When the user has a friend accepted
		# And the friend has the user accepted
		friend = new User()
		user.friends.push friend._id
		friend.friends.push user._id

		# Retrieve the user's friends list
		friend.save ->
			user.save ->
				user.get_accepted_friends_list (accepted_friends_list) ->
					friend._id.equals(accepted_friends_list[0]._id).should.be.true
					done()

	it "should paginate the user's friends ", (done) ->
		# When the user has several friends accepted
		# And the friends accepted the user
		friends = []
		for i in [0...20]
			# Create 20 friends with random fb_id
			friend = new User(fb_id: Math.random().toString(36).substring(7))
			friend.friends.push user._id
			user.friends.push friend._id
			friends.push friend
		# because saving an instance of a user is an asynchronous task
		# We have to keep count of all the users saved to know when to
		# continue.

		# Count how many friends have been saved to db
		friends_saved_count = 0
		# iterate the friends list
		for friend in friends
			# Asynchronous save of a User
			friend.save (err, doc) ->
				console.log "Error #{err}" if err?
				# Update the counter
				friends_saved_count += 1
				# If we finished saving
				if friends_saved_count == friends.length
					# CONTINUE
					user.save (err, doc)->
						console.log "Error #{err}" if err?
						options = [
							{ "skip": 0  ,	"limit": 10  }
							{ "skip": 10 ,	"limit": 20 }
						]
						friends_count = 0
						for option in options
							# Capture the option object
							do (option) ->
								# Define the callback that checks for the asserts
								cb = (accepted_friends_list) ->
										# Compare all the friends
										for i in [0...accepted_friends_list.length]
											# Option.skip + 1 is the last position we used
											friends[option.skip + i]._id.equals(accepted_friends_list[i]._id).should.be.true
										friends_count += accepted_friends_list.length
										# if Finished comparing friends
										if friends_count == friends.length
											done()
								# Get the accepted friends list
								user.get_accepted_friends_list( cb, 
													option.skip, option.limit)