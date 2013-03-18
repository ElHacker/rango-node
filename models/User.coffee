mongoose = require 'mongoose'

User = new mongoose.Schema(
  first_name: String
  last_name: String
  fb_id: { type: String, unique: true }
  email: String
  gcm_id: String
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


User.methods.get_pending_friend_requests = (callback, skip=null, limit=null) ->
	@.db.model('User').find(
				{ fb_id: { $nin: @.friends }, friends: @.fb_id }, #query
				[],	# fields
				{ skip: skip, limit: limit },	#options
				(err, pending_friend_requests) ->
					callback(pending_friend_requests)
	)

User.methods.delete_friend = (friend_fb_id, callback) ->
  # First Delete the friend_fb_id from the user
  @.db.model('User').update(
    { fb_id: {$in: [ @.fb_id, friend_fb_id ] } }, #query
    { $pullAll: { friends : [ @.fb_id, friend_fb_id ]  } },
    { multi: true },
    (err, num_affected, raw) ->
      unless err?
        console.log "affected #{num_affected}"
        callback(200)
      else
        console.log err
        callback(500)
  )
module.exports = mongoose.model 'User', User
