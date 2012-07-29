# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # Represents a cache entry.
  class Entry
    # The key for this entry.
    attr_accessor :key

    # The hashed (unique) key for this entry.
    attr_accessor :hash

    # The value contained in this entry.
    attr_accessor :value

    # The expected TTL of the entry, in milliseconds.
    attr_accessor :ttl

    # The last update date of the entry, in UNIX timestamp (with milliseconds).
    attr_accessor :updated_at

    # Creates a new entry.
    #
    # @param key [String] The key for this entry.
    # @param value [Object] The value contained in this entry.
    # @param hash [String] The hash for this entry. Should be unique. It is automatically created if not provided.
    # @param ttl [Integer] The time to live (TTL) for this entry. If set to 0 then the entry is not cached.
    def initialize(key, value, hash = nil, ttl = 360000)
      hash = self.class.hashify_key(key) if hash.blank?
      self.key = key
      self.hash = hash
      self.value = value
      self.ttl = ttl
      self.refresh
    end

    # Refreshes the entry.
    #
    # @param save [Boolean] If to save the refresh value in the cache.
    # @return [Float] The new updated_at value.
    def refresh(save = false)
      self.updated_at = Time.now.to_f

      Elephas::Cache.provider.write(self.hash, self) if save
      self.updated_at
    end

    # Checks if the entry is still valid.
    #
    # @param provider [Provider::Base] The provider to use for the check.
    # @return [Boolean] `true` if the entry is still valid, `false` otherwise.
    def valid?(provider = nil)
      provider ||= ::Elephas::Cache.provider
      provider.now - self.updated_at < self.ttl / 1000
    end

    # Compare to another Entry.
    #
    # @param other [Entry] The entry to compare with
    # @return [Boolean] `true` if the entries are the same, `false` otherwise.
    def ==(other)
      other.is_a?(::Elephas::Entry) && [self.key, self.hash, self.value] == [other.key, other.hash, other.value]
    end

    # Returns a unique hash for the key.
    #
    # @param key [String] The key to hashify.
    # @return [String] An unique hash for the key.
    def self.hashify_key(key)
      Digest::SHA2.hexdigest(key.ensure_string)
    end

    # Ensure that the value is an Entry.
    #
    # @param value [Object] The object to check.
    # @param key [Object] The key associated to this object.
    # @return [Entry] The wrapped object.
    def self.ensure(value, key, options = {})
      rv = value

      if !rv.is_a?(::Elephas::Entry) then
        options = {} if !options.is_a?(Hash)

        ttl = [options[:ttl].to_integer, 0].max
        hash = options[:hash] || ::Elephas::Entry.hashify_key(key.ensure_string)

        rv = ::Elephas::Entry.new(key, rv, hash, ttl)
      end

      rv
    end
  end
end