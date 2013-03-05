gcm = require 'node-gcm'
User = require '../models/User'
GCMManager = require '../libs/GCMManager'

module.exports = 
  index : (req, res) ->
    res.render "index", title: "Express"
  gcm: (req, res) ->
    user_fb_id = req.query['fb_id']
    message = req.query['msg']
    GCMManager.notify user_fb_id, message, null, null
    message = new gcm.Message()
    sender = new gcm.Sender('AIzaSyCVbBMMeGKe0qNClQCfuUDx6IlbWq3DNww')
    res.send ("Notification sent")
