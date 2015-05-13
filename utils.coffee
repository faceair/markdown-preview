_ = require 'underscore'
utils = require 'blueimp-md5'

_.extend utils,
  randomString: (length) ->
    char_map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

    result = _.map _.range(0, length), ->
      return char_map.charAt Math.floor(Math.random() * char_map.length)

    return result.join ''

module.exports = utils
