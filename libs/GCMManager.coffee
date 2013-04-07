gcm = require 'node-gcm'
User = require '../models/User'

class GCMManager
  # Set the secret api key
  @sender: new gcm.Sender('AIzaSyCVbBMMeGKe0qNClQCfuUDx6IlbWq3DNww')
  @notify: (to_fb_id, from_fb_id ,message_content = "Incomming call", title = "Rango", collapse_key, action = "home") ->

    User.findOne fb_id: from_fb_id, (err, from_user) ->
      unless err? and from_user
        User.findOne fb_id: to_fb_id, (err, user) ->
          unless err?
            if user
              # Optional
              message = new gcm.Message()
              message.addData('title', title)
              message.addData('message', message_content + " from #{from_user.first_name} #{from_user.last_name}")
              message.addData('from_fb_id', from_fb_id)
              message.addData('action', action)
              message.collapseKey = collapse_key
              message.delayWhileIdle = false
              message.timeToLive = 0
              registrationIds = []
              # At least one reg id is required
              registrationIds.push(user.gcm_id)
              # Parameters:
              # message-literal, registrationIds-array, No. of retries, callback-function
              GCMManager.sender.send message, registrationIds, 5, (err, result) ->
                if err
                  console.log err
                console.log result
            else
              console.log "Not user with fb_id: #{to_fb_id}"
          else
            console.log "Error db: #{error}"

module.exports = GCMManager
