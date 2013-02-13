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
        new_user.save (err)->
            unless err?
                res.json(201, {})
            else
                res.json(500, err)
    
    update_user: (req, res) ->
        fb_id = req.params.fb_id
        user_to_update = JSON.parse(req.body.user)
        User.findOne 'fb_id':fb_id, (err, user)->
            unless err?
                if user?
                    user.first_name = user_to_update.first_name if user_to_update.first_name?
                    user.last_name = user_to_update.last_name if user_to_update.last_name?
                    user.save (err)->
                        unless err?
                            res.json(200)
                        else
                            res.json(500, err)
                else
                    res.json(404, msg:'User not found')
            else
                res.json(500, err)

    get_user_friends: (req, res) ->
        fb_id = req.params.fb_id
        skip = req.query.skip
        limit = req.query.limit
        User.findOne 'fb_id':fb_id, (err, user) ->
            unless err?
                cb = (accepted_friends_list) ->
                    res.json(200, accepted_friends_list)
                user.get_accepted_friends_list(cb, skip, limit) 
            else
                res.json(500, err)

    get_friend_requests: (req, res)->
        fb_id = req.params.fb_id
        skip = req.query.skip
        limit = req.query.limit
        User.findOne 'fb_id':fb_id, (err, user)->
          unless err?
              cb = (pending_friend_requests) ->
                  res.json(200, pending_friend_requests)
              user.get_pending_friend_requests(cb, skip, limit)
          else
              res.json(500, err)

    # This method looks more like a PUT
    # than a POST, maybe change later.
    create_friend_request: (req, res) ->
        requested_fb_id = req.params.fb_id
        requester_user = JSON.parse req.body.user
        User.findOne fb_id: requester_user.fb_id, (err, user)->
            unless err?
                if user?
                    user.friends.push requested_fb_id
                    user.save (err) ->
                      unless err?
                          res.json(201)
                      else
                          res.json(500, err)
                else
                    res.json(404, msg: "User not found")
            else
              res.json(500, err)
        res.json(201, {})
