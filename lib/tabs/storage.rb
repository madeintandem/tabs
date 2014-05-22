module Tabs
  module Storage
    extend self

    def redis
      @redis ||= Config.redis
    end

    def tabs_key(key)
      if Tabs::Config.prefix.blank?
        "tabs:#{key}"
      else
        "tabs:#{Tabs::Config.prefix}:#{key}"
      end
    end

    def exists(key)
      redis.exists(tabs_key(key))
    end

    def expireat(key, unix_timestamp)
      redis.expireat(tabs_key(key), unix_timestamp)
    end

    def ttl(key)
      redis.ttl(tabs_key(key))
    end

    def get(key)
      redis.get(tabs_key(key))
    end

    def mget(*keys)
      prefixed_keys = keys.map { |k| tabs_key(k) }
      redis.mget(*prefixed_keys)
    end

    def set(key, value)
      redis.set(tabs_key(key), value)
    end

    def del(*keys)
      return 0 if keys.empty?
      prefixed_keys = keys.map { |k| tabs_key(k) }
      redis.del(*prefixed_keys)
    end

    def del_by_prefix(pattern)
      keys = redis.keys("#{tabs_key(pattern)}*")
      return 0 if keys.empty?
      redis.del(*keys)
    end

    def incr(key)
      redis.incr(tabs_key(key))
    end

    def decr(key)
      redis.decr(tabs_key(key))
    end

    def rpush(key, value)
      redis.rpush(tabs_key(key), value)
    end

    def sadd(key, *values)
      redis.sadd(tabs_key(key), *values)
    end

    def smembers(key)
      redis.smembers(tabs_key(key))
    end

    def smembers_all(*keys)
      redis.pipelined do
        keys.map{ |key| smembers(key)}
      end
    end

    def sismember(key, value)
      redis.sismember(tabs_key(key), value)
    end

    def hget(key, field)
      redis.hget(tabs_key(key), field)
    end

    def hset(key, field, value)
      redis.hset(tabs_key(key), field, value)
    end

    def hdel(key, field)
      redis.hdel(tabs_key(key), field)
    end

    def hkeys(key)
      redis.hkeys(tabs_key(key))
    end

    def hincrby(key, field, value)
      redis.hincrby(tabs_key(key), field, value)
    end

    def hgetall(key)
      redis.hgetall(tabs_key(key))
    end

  end
end
