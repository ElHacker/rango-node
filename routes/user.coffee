User = require '../models/User'

module.exports =
	# Retrieves all the users
	list: (req, res) ->
		User.find( {} , (err, users) ->
			unless err
				res.json 200, users
			else
				res.json 500, err
		)

	one_user: (req, res)->
		fb_id = req.params.fb_id
		User.findOne  fb_id : fb_id, (err, user)->
			unless err
				res.json 200, user
			else
				res.json 500, err