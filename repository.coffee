_ = require 'underscore'
Q = require 'q'
{md5} = require './utils'
OP = require './op'

class Branch
  constructor: (@HEAD = '') ->
    @database = []
    @push []

  getHead: ->
    _.last @database

  commit: (hash, changes) ->
    Q.promise (resolve, reject) =>
      if _.isEmpty changes
        reject new Error 'empty changes'

      if @getHead().hash is hash
        @HEAD = OP.applyChanges @HEAD, changes
        @push changes
        resolve @
      else
        i = null
        old_rows = _.compact _.map @database, (row, index) ->
          if row.hash is hash
            i = index
          if i and index > i
            return row
          else
            return

        if _.isEmpty old_rows
          reject new Error 'unknown hash'
        else
          old_changes = _.map old_rows, (row) ->
            return row.changes
          old_changes.push changes
          new_changes = OP.mergeChanges old_changes
          @HEAD = OP.applyChanges @HEAD, new_changes
          @push new_changes
          resolve @

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

  push: (changes) ->
    @database.push
      data: @HEAD
      hash: md5(@HEAD)
      changes: changes

module.exports = class Repository
  constructor: (data) ->
    @branches =
      master: new Branch(data)

  createBranch: (name) ->
    @branches[name] = new Branch(@branches.master.getHead().data)
    return @branches[name]

  deleteBranch: (name) ->
    delete @branches[name]
