_ = require 'underscore'
{md5} = require './utils'

class Branch
  constructor: (@HEAD = '', changes = []) ->
    @database = []
    @push()

    unless _.isEmpty changes
      @applyChanges @HEAD, changes

  getHead: ->
    return @HEAD

  commit: (changes) ->
    return unless changes
    changes.map (change) =>
      switch change.t
        when 'r'
          @HEAD = @HEAD.substr(0, change.s) + @HEAD.substr(change.e)
        when 'i'
          @HEAD = @HEAD.substr(0, change.s) + change.v +  @HEAD.substr(change.s)
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

  diffBranch: ->

  mergeBranches: (callback) ->
    @branches.map (branches) ->
