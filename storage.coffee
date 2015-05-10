redis = require 'redis'
_ = require 'underscore'
Q = require 'q'
config = require './config'

class Redis
  constructor: ({host, port, password}) ->
    @redis = redis.createClient port, host,
      auth_pass: password

    _.extend @,
      get: Q.denodeify @redis.get.bind @redis
      del: Q.denodeify @redis.del.bind @redis
      set: Q.denodeify @redis.set.bind @redis
      setEx: Q.denodeify @redis.setex.bind @redis

module.exports = new Redis config.redis
