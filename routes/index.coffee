gcm = require 'node-gcm'
User = require '../models/User'

module.exports = 
  index : (req, res) ->
    res.render "index", title: "Express"
  gcm: (req, res) ->
    message = new gcm.Message()
    sender = new gcm.Sender('AIzaSyCVbBMMeGKe0qNClQCfuUDx6IlbWq3DNww')

    # Optional
    message.addData('title', 'Rango')
    msg = req.query['msg'] || "Te llaman!!"
    console.log msg
    message.addData('message', msg)
    message.addData('msgctn', '1')
    message.collapseKey = 'demo'
    message.delayWhileIdle = true
    message.timeToLive = 3

    user_fb_id = req.query['fb_id']

    User.findOne fb_id: user_fb_id, (err, user) ->
      unless err?
        registrationIds = []
        console.log user
        # At least one is required
        registrationIds.push(user.gcm_id)
        console.log registrationIds
        # Parameters:
        # message-literal, registrationIds-array, No. of retries, callback-function
        sender.send message, registrationIds, 5, (err, result) ->
          if err
            console.log err
          console.log result
          res.send ("Notification sent")
      else
        res.send(500, err)
