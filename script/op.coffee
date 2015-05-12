_ = require 'underscore'
OP = {}

OP.diffString = (oldval, newval) ->
  return [] if oldval is newval

  minLength = Math.min oldval.length, newval.length

  for commonStart in [0...minLength]
    unless oldval.charAt(commonStart) is newval.charAt(commonStart)
      break

  for commonEnd in [0...(minLength - commonStart)]
    unless oldval.charAt(oldval.length - 1 - commonEnd) is newval.charAt(newval.length - 1 - commonEnd)
      break

  changes = []
  if oldval.length isnt (commonStart + commonEnd)
    changes.push
      t: 'r'
      s: commonStart
      e: oldval.length - commonEnd

  if newval.length isnt (commonStart + commonEnd)
    changes.push
      t: 'i'
      s: commonStart
      v: newval.slice(commonStart, newval.length - commonEnd)

  return changes

OP.applyChanges = (val, changes) ->
  for change in changes
    switch change.t
      when 'r'
        val = val.substr(0, change.s) + val.substr(change.e)
      when 'i'
        val = val.substr(0, change.s) + change.v + val.substr(change.s)
  return val

OP.mergeChanges = (changes_arr) ->
  changes = _.flatten changes_arr

  removes = _.filter changes, (change) ->
    change.t is 'r'
  for remove, i in removes
    conflict = false
    for remove_other, j in removes when j > i
      other_in = remove.s < remove_other.s and remove_other.s < remove.e
      self_in = remove_other.s < remove.s and remove.s < remove_other.e
      if other_in or self_in
        conflict = true

      if conflict
        removes = _.without removes, remove
        removes = _.without removes, remove_other
        removes.push
          t: 'r'
          s: Math.min(remove.s, remove_other.s)
          e: Math.max(remove.e, remove_other.e)

  inserts = _.filter changes, (change) ->
    change.t is 'i'
  for remove in removes
    for insert in inserts
      if remove.s < insert.s and insert.s < remove.e
        inserts = _.without inserts, insert
        inserts.push
          t: 'i'
          s: remove.s
          v: insert.v

  return _.uniq _.union(removes, inserts), (change) ->
    JSON.stringify change

module.exports = OP
