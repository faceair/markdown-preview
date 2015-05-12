_ = require 'underscore'
Q = require 'q'
{md5} = require './utils'
OP = require './op'

class Branch
  constructor: (@HEAD = '') ->
    @database = []
    @push()

  getHead: ->
    _.last @database

  commit: (hash, changes) ->
    Q.promise (resolve, reject) =>
      if _.isEmpty changes
        reject new Error 'empty changes'
      if @getHead().hash is hash
        @HEAD = OP.applyChanges @HEAD, changes
        @push()
        resolve @
      else
        reject new Error 'unknown hash'

  merge: (branch) ->
    Q.promise (resolve, reject) =>
      {hash, data} = @getHead()
      is_old = _.find branch.database, (row) ->
        row.hash is hash
      if is_old
        changes = OP.diffString data, _.last(branch.database).data
        @commit(hash, changes).then =>
          resolve @
        .catch reject
      else
        reject new Error 'merge reject'

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
    @branches[name] = new Branch(@branches.master.getHead().data)
    return @branches[name]

  deleteBranch: (name) ->
    delete @branches[name]
