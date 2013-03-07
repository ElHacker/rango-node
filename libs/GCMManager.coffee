gcm = require 'node-gcm'
User = require '../models/User'

class GCMManager
  # Set the secret api key
  @sender: new gcm.Sender('AIzaSyCVbBMMeGKe0qNClQCfuUDx6IlbWq3DNww')
  @notify: (to_fb_id, from_fb_id ,message_content = "Incomming call", title = "Rango", collapse_key="demo") ->
    # Optional
    message = new gcm.Message()
    message.addData('title', title)
    message.addData('message', message_content)
    message.addData('from_fb_id', from_fb_id)
    message.collapseKey = collapse_key
    message.delayWhileIdle = true
    message.timeToLive = 3

    User.findOne fb_id: to_fb_id, (err, user) ->
      unless err?
        if user
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
