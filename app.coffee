express = require 'express'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require 'path'
sockets = []

app.use express.static(path.join(__dirname, 'statics'))

app.use '/', (req, res) ->
  res.sendFile path.join(__dirname, 'index.html')

io.on 'connection', (socket) ->
  socket.on 'data', (data) ->
    socket.broadcast.emit 'data', data

http.listen 5748, ->
