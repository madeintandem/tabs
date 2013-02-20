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
