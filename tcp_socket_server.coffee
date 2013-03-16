net = require('net')
util = require('util')
GCMManager = require './libs/GCMManager'

# Every new tcp socket connection must SEND a message
# indicating their fb_id and the target_fb_id inside a 
# formatted message and every message has the form:
#
# [fb_id],[target_fb_id][delimiter]
# 
# This will allow to identify the new socket client
# and who it wants to talk to.

# Message Delimiter
MSG_DELIMITER = "\n"

# Keep track of the socket clients
clients = {}

extract_id_and_target = (message) ->
  # get the chunk with the fb_id and target_fb_if in it
  id_and_target = message.slice(0, message.indexOf(MSG_DELIMITER))
  # Separate the both sides of the info
  splitted_message = id_and_target.split(',')
  id_and_target = 
    fb_id : splitted_message[0]
    target_fb_id : splitted_message[1]
  console.log "FB_ID: #{id_and_target.fb_id}, TARGET_FB_ID #{id_and_target.target_fb_id}"
  id_and_target

give_identity_and_target = (socket, source_id, target_id) ->
  # Identify this socket client
  # with a given fb_id
  socket.fb_id = source_id
  # Indentify to which friend
  # this socket client wants to connect to
  socket.target_fb_id = target_id
  # put this client on the hash
  clients[socket.fb_id] = socket
  # This socket got identified
  socket.identified = true

# precondition: a socket with source_id is connected
# Makes a call request to the target id from the source id
request_for_call = (source_id, target_id) ->
  unless clients[target_id]?
    # If target is not connected
    # Notify the target of a new incomming call
    GCMManager.notify target_id, source_id, null, null, null, "call"
  else
    # Target is connected (probably waiting), start the call
    start_call(source_id, target_id)

# Precondition: both sockets with source_id and target_id are connected
# Starts the connection between two users
start_call = (source_id, target_id) ->
  console.log "START"
  clients[source_id].write("START\n")
  clients[target_id].write("START\n")

module.exports =
  # starts a TCP server
  createServer : ()->
    tcp_server = net.createServer(
      (socket) ->
        console.log("TCP SERVER CONNECTED: ")


        buffered_str_data = ""

        socket.on 'data', (data)->
          # The socket client had not provided the required
          # data to establish a connection
          if not socket.identified
            str_data = data.toString('utf-8')
            if (str_data.indexOf(MSG_DELIMITER) != -1 )
              str_data = str_data.replace(/\r/g, "")
              # Concatenate buffered data and new data
              full_str_data = buffered_str_data + str_data
              ids = extract_id_and_target(full_str_data)

              give_identity_and_target(socket, ids.fb_id, ids.target_fb_id)
              request_for_call(ids.fb_id, ids.target_fb_id)
            else
              # If not found the delimiter save it to a buffer
              buffered_str_data += str_data
          # The socket client already provided the required
          # data to establish a connection
          else
            if clients[socket.target_fb_id]?
              # write to target socket client
              flushed = clients[socket.target_fb_id].write(data)
              # Pause the socket stream when the write stream gets saturated
              socket.pause() unless flushed
            else
              socket.write("ERROR 500, NO SOCKET WITH THAT ID")

        socket.on 'drain', ()->
          if clients[socket.target_fb_id]?
            # Resume the socket stream when the write stream gets hungry
            clients[socket.target_fb_id].resume()


        # Remove client from the list when it leaves
        socket.on 'end', ()->
          delete clients[socket.fb_id]
          console.log(socket.fb_id + " left the chat\r\n")


    ).listen(8090, ()->	# 'listening' listener
    console.log("TCP SERVER BOUND")
    )
    tcp_server
