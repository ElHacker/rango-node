gcm = require 'node-gcm'
User = require '../models/User'
GCMManager = require '../libs/GCMManager'

module.exports = 
  index : (req, res) ->
    res.render "index", title: "Express"
  gcm: (req, res) ->
    to_fb_id = req.query['to_fb_id']
    message = req.query['msg']
    from_fb_id = req.query['from_fb_id']
    collapse_key = req.query['collapse_key']
    GCMManager.notify to_fb_id, from_fb_id, message, null, null
    message = new gcm.Message()
    sender = new gcm.Sender('AIzaSyCVbBMMeGKe0qNClQCfuUDx6IlbWq3DNww')
    res.send ("Notification sent")
