mongoose = require 'mongoose'
User  = require '../../models/User'
require 'should'
http = require('http')

describe 'Rest-API for User', ->

    # Override this object to specify the options for each case
    default_options = {}


    # Call this function to make any http request
    # options define the method, host, port and path
    # the callback will receive the json_object and responde returned by the server
    # the done function is used in the error callback
    make_request = (options, callback, done, data="") ->
        req = http.request(
            options
            (res) ->
                res.setEncoding('utf8')

                raw_data = ""

                res.on('data', (chunk) ->
                    raw_data += chunk
                )

                res.on('end', () ->
                    json_data = JSON.parse(raw_data)
                    callback(json_data, res)
                )
        )
        req.on('error', (e) ->
            done(e)
        )
        req.write(data)
        req.end()

    before (done) ->
        mongoose.connect 'mongodb://localhost/rango-test', ->
            # Clean User docs
            User.remove () ->
                # Create a new and clean user each time
                user = new User(
                        first_name: 'Braulio'
                        last_name: 'Chavez'
                        fb_id: "12345678"
                        friends: ["98765432"]
                        created_at: Date.now()
                        updated_at: Date.now()
                    )
                user.save done

    beforeEach (done) ->
        # Reset Default options
        default_options =
            method: 'GET'
            hostname: "127.0.0.1"
            port: 3000
            path: '/'

        done()

    it 'should GET a list of Users', (done) ->
        default_options.path = '/users.json'
        cb = (json_data, res)->
            res.statusCode.should.be.equal(200)
            json_data.should.be.instanceof(Array)
            done()
        make_request(default_options, cb, done)

    it 'should GET one specific User', (done) ->
        fb_id = '12345678'
        default_options.path = "/users/#{fb_id}.json"
        cb = (json_data, res) ->
            res.statusCode.should.be.equal(200)
            json_data.should.have.property('first_name')
            json_data.first_name.should.be.eql("Braulio")
            done()
        make_request(default_options, cb, done)

    it 'should POST a new User', (done) ->
        user = {
            first_name : "Kalypso"
            last_name : "Paredes"
            fb_id: "98765432"
            friends: ["12345678"]
            }
        post_data = "user=" + JSON.stringify(user)
        default_options.path = "/users.json"
        default_options.method = "POST"
        default_options.headers = 
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': post_data.length
        cb = (json_data, res) ->
            res.statusCode.should.be.equal(201)
            done()
        make_request(default_options, cb, done, post_data)

    it 'should PUT (update) a user', (done) ->
        user = {
          first_name: "Kalypso Erika"
          last_name: "Paredes Morales"
        }
        fb_id = "98765432"
        post_data = "user=" +  JSON.stringify(user)
        default_options.path = "/users/#{fb_id}.json"
        default_options.method = "PUT"
        default_options.headers = 
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Content-Length': post_data.length
        cb = (json_data, res) ->
          res.statusCode.should.be.equal(200)
          done()
        make_request(default_options, cb, done, post_data)

    describe "Sub-Resource Friends", ->
        
        it "should GET all user's accepted friends", (done) ->
            fb_id = "12345678"
            default_options.path = "/users/#{fb_id}/friends.json"
            default_options.method = "GET"
            cb = (json_data, res) ->
                res.statusCode.should.be.equal(200)
                json_data[0].should.have.property('first_name')
                json_data[0].first_name.should.eql("Kalypso Erika")
                done()
            make_request(default_options, cb, done)

        it "should GET all user's pending friend requests", (done) ->
          fb_id = "12345678"
          default_options.path = "/users/#{fb_id}/friends/requests.json"
          default_options.method = "GET"
          new_user = new User(
            first_name : "Foo"
            last_name : "Bar"
            friends : ["12345678"]
          )
          new_user.save () ->
            cb = (json_data, res)->
              res.statusCode.should.be.equal(200)
              json_data[0].should.have.property('first_name')
              json_data[0].first_name.should.eql('Foo')
              done()
            make_request(default_options,cb, done)

        it 'should POST a friend request to a user', (done) ->
            # fb_id of the user that receives the friend request
            fb_id = "12345678"
            # Requesting user
            # This is the user who makes the friend request
            new_user = new User(
              first_name : "FooCamp"
              last_name: "BarCamp"
              fb_id: "012345"
            )
            new_user.save (err, doc) ->
                post_data = "user=" + JSON.stringify(doc)
                default_options.path = "/users/#{fb_id}/friends/requests.json"
                default_options.method = "POST"
                default_options.headers = 
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Content-Length': post_data.length
                cb = (json_data, res) ->
                    res.statusCode.should.be.equal(201)
                    done()
                make_request(default_options, cb, done, post_data)

