_ = require 'underscore'
{md5} = require './utils'
OP = require './op'

class Branch
  constructor: (@HEAD = '', changes = []) ->
    @database = []
    @push()

    unless _.isEmpty changes
      @commit changes

  getHead: ->
    return @HEAD

  commit: (changes) ->
    return if _.isEmpty changes
    @HEAD = OP.applyChanges @HEAD, changes
    @push()

  push: ->
    @database.push
      data: @HEAD
      hash: md5(@HEAD)
      time: _.now()

module.exports = class Repository
  constructor: (data) ->
    @branches =
      master: new Branch(data)

  createBranch: (name) ->
    @branches[name] = new Branch(@branches.master.getHead())
    return @branches[name]

  deleteBranch: (name) ->
    delete @branches[name]

  mergeBranches: (name_1, name_2 = 'master') ->
    return unless @branches[name_1]
    changes = OP.diffString @branches[name_1].getHead(), @branches[name_2].getHead()
    @branches[name_2].commit changes
