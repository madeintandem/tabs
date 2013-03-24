module Tabs
  module Storage
    extend self

    def redis
      @redis ||= Config.redis
    end

    def exists(key)
      redis.get("tabs:#{key}")
    end

    def get(key)
      redis.get("tabs:#{key}")
    end

    def mget(*keys)
      prefixed_keys = keys.map { |k| "tabs:#{k}" }
      redis.mget(*prefixed_keys)
    end

    def set(key, value)
      redis.set("tabs:#{key}", value)
    end

    def del(*keys)
      return 0 if keys.empty?
      prefixed_keys = keys.map { |k| "tabs:#{k}" }
      redis.del(*prefixed_keys)
    end

    def del_by_prefix(pattern)
      keys = redis.keys("tabs:#{pattern}*")
      return 0 if keys.empty?
      redis.del(*keys)
    end

    def incr(key)
      redis.incr("tabs:#{key}")
    end

    def rpush(key, value)
      redis.rpush("tabs:#{key}", value)
    end

    def sadd(key, *values)
      redis.sadd("tabs:#{key}", *values)
    end

    def smembers(key)
      redis.smembers("tabs:#{key}")
    end

    def sismember(key, value)
      redis.sismember("tabs:#{key}", value)
    end

    def hget(key, field)
      redis.hget("tabs:#{key}", field)
    end

    def hset(key, field, value)
      redis.hset("tabs:#{key}", field, value)
    end

    def hdel(key, field)
      redis.hdel("tabs:#{key}", field)
    end

    def hkeys(key)
      redis.hkeys("tabs:#{key}")
    end

  end
end
