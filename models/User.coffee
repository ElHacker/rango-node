mongoose = require 'mongoose'

User = new mongoose.Schema(
	first_name: String
	last_name: String
	fb_id: { type: String, unique: true }
	friends: [ String ] 
	created_at: { type: Date, default: Date.now() }
	updated_at: { type: Date, default: Date.now() }
)


User.methods.get_accepted_friends_list = (callback, skip=null, limit=null) ->
	@.db.model('User').find(
				{ fb_id: { $in: @.friends }, friends: @.fb_id }, #query
				[],	# fields
				{ skip: skip, limit: limit },	#options
				(err, accepted_friends_list) ->
					callback(accepted_friends_list)
	)

module.exports = mongoose.model 'User', User
