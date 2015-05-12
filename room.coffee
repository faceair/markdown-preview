Repository = require './repository'
{EventEmitter} = require 'events'
storage = require './storage'
config = require './config'
_ = require 'underscore'
Q = require 'q'

class Member
  constructor: (@socket, {@room, @room_id, @repository, @members}) ->
    _.extend @,
      id: @socket.id
      branches: @repository.branches
      master: @repository.branches.master
      branch: @repository.createBranch(@socket.id)
      status: 'wait'

    @socket.on 'change', @change.bind(@)
    @socket.on 'disconnect', =>
      @repository.deleteBranch @id

  change: ({h: hash, c: changes}) ->
    return if _.isEmpty changes
    @status = 'deal'

    @branch.commit(hash, changes).then =>
      @master.merge @branch
    .then =>
      Q.all _.compact _.map @room.sockets, (socket) =>
        unless socket.id is @id
          @branches[socket.id].merge @master
    .then =>
      storage.set @room_id, @master.getHead().data
    .then =>
      @socket.broadcast.emit 'change', changes
      @status = 'wait'
    .catch (err) ->
      console.log err.stack

module.exports = class Room
  constructor: (@room_id, io) ->
    @room = io.of "/#{@room_id}"
    storage.get(@room_id).then (base_data) =>

      @repository = new Repository(base_data)
      @room.on 'connection', (socket) =>

        member = new Member socket, @
