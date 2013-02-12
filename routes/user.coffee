User = require '../models/User'

module.exports =
    # Retrieves all the users
    list: (req, res) ->
        User.find( {} , (err, users) ->
          unless err?
            res.json 200, users
          else
            res.json 500, err
        )

    one_user: (req, res)->
        fb_id = req.params.fb_id
        User.findOne  fb_id : fb_id, (err, user)->
          unless err?
            res.json 200, user
          else
            res.json 500, err

    create_user: (req, res) ->
        json_user = JSON.parse(req.body.user)
        new_user = new User(json_user)
        new_user.save (err, doc)->
            unless err?
                res.json(201, {})
            else
                res.json(500, err)
    
    update_user: (req, res) ->
        fb_id = req.params.fb_id
        console.log fb_id
        user_to_update = JSON.parse(req.body.user)
        User.findOne 'fb_id':fb_id, (err, user)->
            unless err?
                console.log user
                if user?
                    user.first_name = user_to_update.first_name if user_to_update.first_name?
                    user.last_name = user_to_update.last_name if user_to_update.last_name?
                    user.save (err)->
                        unless err?
                            res.json(200)
                        else
                            res.json(500)
                else
                    res.json(404, msg:'User not found')
            else
                res.json(500, err)
