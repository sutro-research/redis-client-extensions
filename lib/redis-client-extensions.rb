require 'redis'

module RedisClientExtensions

  # Store a Ruby hash into a redis hash
  #
  # Examples:
  #   $redis.hmultiset("my-key", { name: "tom", color: "red" })
  #   $redis.hget("my-key", "name") # => "tom"
  #   $redis.hget("my-key", "color") # => "red"
  #
  # Returns 'OK'
  def hmultiset(hkey, hash)
    hmset(hkey, *(hash.map { |k, v| [k, v] }.flatten))
    'OK'
  end


  # Wrapper for #scan to iterate over a set of keys matching a pattern
  #
  # options - Hash of options
  #   :match - String pattern to match against, ex: "mypattern*"
  #   :count - (Optional) Integer hint for number of elements to return
  #     each iteration
  #
  # <block> - Proc to handle each batch of keys
  #   Will be invoked with Array[String] of key names
  #
  # Ex:
  #
  #   $redis.find_keys_in_batches(match: "mypattern*", count: 100) do |keys|
  #     puts "Got batch of #{keys.count} keys"
  #     puts "Values for this batch: #{$redis.mget(keys)}"
  #   end
  #
  # See Redis docs for SCAN.
  #
  # Returns nothing
  def find_keys_in_batches(options={})
    cursor = 0
    while (cursor, keys = scan(cursor, options); cursor.to_i != 0)
      yield keys
    end

    yield keys # Leftovers from final iteration
  end


  # Parse the value stored at `key` as an Integer,
  # or return nil if it doesn't exist
  #
  # key - String key
  #
  # Return Integer or nil
  def get_i(key)
    val = get(key)
    val.nil? ? nil : val.to_i
  end


  # Get/set a value cached in a key
  # Values are marshalled to preserve class
  #
  # key - String key name
  # expires_in: Integer TTL of the key, in seconds
  # block - Proc to compute the value to be cached on miss
  #
  # Returns cached value or result of evaluating <block>
  def cache_fetch(key, expires_in:, &block)
    if ret = mload(key)
      ret
    else
      val = block.call
      mdump(key, val)
      expire(key, expires_in)
      val
    end
  end


  # Load a Marshalled value stored at <key>
  # Returns nil if key does not exist
  #
  # Returns class of marshalled value
  def mload(key)
    if val = get(key)
      Marshal.load(val)
    end
  end


  # Store a marshalled value at <key>
  #
  # key - String key
  # val = Any value
  #
  # Returns 'OK'
  def mdump(key, val)
    set(key, Marshal.dump(val))
  end

end


Redis.send(:include, RedisClientExtensions)
defined?(MockRedis) and MockRedis.send(:include, RedisClientExtensions)
