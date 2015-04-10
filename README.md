# RedisClientExtensions

A set of useful core extensions to the [redis-rb](https://github.com/redis/redis-rb) client library, extracted from
[KnowMyRankings](https://www.knowmyrankings.com/).




## Installation

Add this line to your application's Gemfile:

    gem 'redis-client-extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis-client-extensions


The extensions will add themselves to the Redis client automatically - in our Rails app, we have
an initializer that looks something like

```ruby
require 'redis-client-extensions'

$redis = Redis.new(...)
```

The extensions also work with [MockRedis](https://github.com/causes/mock_redis) out of the box
if it is installed.

Note that the library is coded against Ruby 2.1+.

## Usage

Currently added functions are:

- `hmultiset(hkey, hash)` - convenience method for storing a Ruby hash into a redis hash

```ruby
$redis.hmultiset("my-hash", { name: "tom", color: "red" })
$redis.hget("my-hash", "name") # => "tom"
$redis.hget("my-hash", "color") # => "red"
```

- `find_keys_in_batches(options)` - A wrapper for [SCAN](http://redis.io/commands/scan) to iterate over keys matching a pattern.
  Options are passed through to SCAN.

```ruby
$redis.find_keys_in_batches(match: "mypattern*", count: 100) do |keys|
  puts "Got batch of #{keys.count} keys"
  puts "Values for this batch: #{$redis.mget(keys)}"
end
```

- `get_i(key)` - Parse an Integer stored at a key

```ruby
$redis.get_i('price') # => 9
```

- `cache_fetch(key, expires_in:, &block)` - Get or set a value (to be stored with [Marshal](http://www.ruby-doc.org/core-2.1.2/Marshal.html)) expiring in some number of seconds

```ruby
# Initial cache miss, block evaluated to store value
ret = $redis.cache_fetch('my-key', expires_in: 60) do
  'cached-value'
end
# => 'cached-value'
#
# Calling again retrieves cached value, block will not be called
ret = $redis.cache_fetch('my-key', expires_in: 60) do
  'something-else' # Not called!
end
# => 'cached-value'
```

- `mdump(key, val)` - Serialize and store a value at `key` using Marshal

```ruby
$redis.mdump('my-key', [1,2,3]) # => 'OK'
```

- `mload(key)` - Retrieve a Marshalled value from `key`

```ruby
$redis.mdump('my-key', [1,2,3])
$redis.mload('my-key') # => [1,2,3]
$redis.mload('does-not-exist') # => nil
```


## Contributing

1. Fork it ( http://github.com/sutro-research/redis-client-extensions/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
