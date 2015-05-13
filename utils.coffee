_ = require 'underscore'
crypto = require 'crypto'

exports.md5 = (data) ->
  return crypto.createHash('md5').update(data).digest('hex')

exports.randomString = (length) ->
  char_map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  result = _.map _.range(0, length), ->
    return char_map.charAt Math.floor(Math.random() * char_map.length)

  return result.join ''
