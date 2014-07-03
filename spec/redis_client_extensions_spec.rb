require 'spec_helper'

describe RedisClientExtensions do
  let(:redis) { MockRedis.new }

  context '#hmultiset' do
    let(:key) { 'myhash' }
    let(:hash) do
      {
        one: 'a',
        two: 'b',
        three: 'c'
      }
    end

    it 'sets a redis hash value for each value in the hash' do
      redis.hmultiset(key, hash)

      expect(redis.hget(key, 'one')).to eq 'a'
      expect(redis.hget(key, 'two')).to eq 'b'
      expect(redis.hget(key, 'three')).to eq 'c'
    end
  end


  context '.get_i' do
    it 'parses a value as an integer' do
      redis.set('mykey', 1)

      expect(redis.get_i('mykey')).to eq 1
    end

    it 'returns nil for nonexistent keys' do
      expect(redis.get_i('does-not-exist')).to be_nil
    end
  end


  # No scan in MockRedis. Leaving this test for posterity.
  #
  # context '#find_keys_in_batches' do
  #   before do
  #     redis.set('test:a', 'one')
  #     redis.set('test:b', 'two')
  #     redis.set('test:c', 'three')
  #     redis.set('test:d', 'four')
  #   end
  #
  #   it 'iterates over each key matching a pattern' do
  #     result = []
  #     redis.find_keys_in_batches.each do |keys|
  #       result.concat(redis.mget(keys))
  #     end
  #
  #     expect(result).to eq ['one', 'two', 'three', 'four']
  #   end
  # end


  context '#cache_fetch' do
    let(:key) { "cache-fetch-test" }

    after(:each) { redis.del(key) }

    it 'stores a value into the cache on miss' do
      expect(redis).to receive(:set).with(key, Marshal.dump('cached-value'))
                                    .and_return('cached-value')
      expect(redis).to receive(:expire).with(key, 60)

      redis.cache_fetch(key, expires_in: 60) do
        'cached-value'
      end
    end

    it 'retrieves cached values' do
      redis.set(key, Marshal.dump('cached-value'))
      expect(redis).to_not receive(:set)
      expect(redis).to_not receive(:expire)

      val = redis.cache_fetch(key, expires_in: 300) do
        'wont_be_called'
      end
      expect(val).to eq 'cached-value'
    end
  end


  context '#mload' do
    let(:key) { 'mload-test' }

    it 'retrieves a marshalled value' do
      redis.set(key, Marshal.dump([1,2,3]))
      expect(redis.mload(key)).to eq [1,2,3]
    end

    it 'returns nil for keys that do not exist' do
      expect(redis.mload('does-not-exist')).to be_nil
    end
  end


  context '#mdump' do
    let(:key) { 'medump-test' }

    it 'stores a marshalled value' do
      expect(redis.mdump(key, [1,2,3])).to eq 'OK'

      expect(Marshal.load(redis.get(key))).to eq [1,2,3]
    end
  end

end

