express = require 'express'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require 'path'
_ = require 'lodash'
redis =  require('redis').createClient()
rooms = []

createID = (length = 6) ->
  char_map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  result = _.map _.range(0, length), ->
    return char_map.charAt Math.floor(Math.random() * char_map.length)
  id = result.join ''
  if rooms[id]
    return createID length
  else
    return id

applyChange = (data, changes) ->
  _.map changes, (change) ->
    switch change.t
      when 'r'
        data = data.substr(0, change.s) + data.substr(change.e)
      when 'i'
        data = data.substr(0, change.s) + change.v +  data.substr(change.s)
  return data

createRoom = (id) ->
  return if rooms[id]
  rooms[id] = io.of id
  rooms[id].on 'connection', (socket) ->
    socket.on 'diff', (changes) ->
      redis.get id, (err, data) ->
        data = applyChange data, changes
        redis.set id, data, ->
          socket.broadcast.emit 'diff', changes

app.set 'views', __dirname
app.set 'view engine', 'jade'
app.use express.static(path.join(__dirname, 'statics'))

app.get '/', (req, res) ->
  id = createID()
  createRoom id
  res.redirect "/#{id}"

app.get '/:id', (req, res) ->
  createRoom req.params.id
  redis.get req.params.id, (err, data) ->
    res.render 'room',
      id: req.params.id
      data: data

http.listen 5748, ->
