express = require "express"
mongoose = require "mongoose"
routes = require "./routes"
user = require "./routes/user" 
tcp_socket_server = require './tcp_socket_server'


http = require("http")
path = require("path")

app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  mongoose.connect 'mongodb://localhost/rango-test'  
  app.use express.errorHandler()

app.configure "production", ->
  mongoose.connect 'mongodb://rangoapp:cr4ckth3m4ch1n3!@linus.mongohq.com:10022/app12115702'
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/send_notif", routes.gcm
# REST API
# User resource
app.get "/users.json", user.list
app.get "/users/:fb_id.json", user.one_user
app.post "/users.json", user.create_user
app.put "/users/:fb_id.json", user.update_user
# User's friends subresource
app.get "/users/:fb_id/friends.json", user.get_user_friends
app.get "/users/:fb_id/friends/requests.json", user.get_friend_requests
app.post "/users/:fb_id/friends/requests.json", user.create_friend_request
app.delete "/users/:user_fb_id/friends/:friend_fb_id.json", user.delete_friend
# User's gcm id subresource
app.post "/users/:fb_id/gcm_ids.json", user.create_user_gcm_id

tcpserver = tcp_socket_server.createServer()

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
