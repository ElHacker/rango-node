mongoose = require 'mongoose'

User = new mongoose.Schema(
	first_name: String
	last_name: String
	fb_id: { type: String, unique: true }
	friends: [ mongoose.Schema.ObjectId ]
	created_at: { type: Date, default: Date.now() }
	updated_at: { type: Date, default: Date.now() }
)

module.exports = mongoose.model 'User', User