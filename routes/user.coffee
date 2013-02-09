User = require '../models/User'

module.exports =
	# Retrieves all the users
	list: (req, res) ->
		User.find( {} , (err, doc) ->
			unless err
				res.json(200, doc)
			else
				res.json(500, err)
		)