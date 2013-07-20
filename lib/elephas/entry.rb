# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # Represents a cache entry.
  #
  # @attribute key
  #   @return [String] The key for this entry.
  # @attribute hash
  #   @return [String] The hashed (unique) key for this entry.
  # @attribute value
  #   @return [Object] The value contained in this entry.
  # @attribute ttl
  #   @return [Fixnum] The expected TTL of the entry, in milliseconds.
  # @attribute updated_at
  #   @return [Fixnum] The last update date of the entry, in UNIX timestamp (with milliseconds).
  class Entry
    attr_accessor :key
    attr_accessor :hash
    attr_accessor :value
    attr_accessor :ttl
    attr_accessor :updated_at

    # Creates a new entry.
    #
    # @param key [String] The key for this entry.
    # @param value [Object] The value contained in this entry.
    # @param hash [String] The hash for this entry. Should be unique. It is automatically created if not provided.
    # @param ttl [Integer] The time to live (TTL) for this entry. If set to 0 then the entry is not cached.
    def initialize(key, value, hash = nil, ttl = 360000)
      @key = key
      @hash = hash.present? ? hash : self.class.hashify_key(key)
      @value = value
      @ttl = ttl
      refresh
    end

    # Refreshes the entry.
    #
    # @param save [Boolean] If to save the refresh value in the cache.
    # @param cache [Cache] The cache where to save the entry.
    # @return [Float] The new updated_at value.
    def refresh(save = false, cache = nil)
      @updated_at = get_new_updated_at(@updated_at)
      cache.write(@hash, self) if save && cache
      @updated_at
    end

    # Checks if the entry is still valid.
    #
    # @param backend [Backends::Base] The backend to use for the check.
    # @return [Boolean] `true` if the entry is still valid, `false` otherwise.
    def valid?(backend)
      backend.now - updated_at < ttl / 1000
    end

    # Compares to another Entry.
    #
    # @param other [Entry] The entry to compare with
    # @return [Boolean] `true` if the entries are the same, `false` otherwise.
    def ==(other)
      other.is_a?(::Elephas::Entry) && [@key, @hash, @value] == [other.key, other.hash, other.value]
    end

    # Returns a unique hash for the key.
    #
    # @param key [String] The key to hashify.
    # @return [String] An unique hash for the key.
    def self.hashify_key(key)
      Digest::SHA2.hexdigest(key)
    end

    # Ensures that the value is an Entry.
    #
    # @param value [Object] The object to check.
    # @param key [Object] The key associated to this object.
    # @param options [Hash] Options to manage the value.
    # @return [Entry] The wrapped object.
    def self.ensure(value, key, options = {})
      rv = value

      if !rv.is_a?(::Elephas::Entry) then
        options = options.ensure_hash

        ttl = [options[:ttl].to_integer, 0].max
        hash = options[:hash] || ::Elephas::Entry.hashify_key(key)

        rv = ::Elephas::Entry.new(key, rv, hash, ttl)
      end

      rv
    end

    private
      # Makes sure a new updated at is generated.
      #
      # @param initial [Float] Old value.
      # @return [Float] New value.
      def get_new_updated_at(initial)
        rv = Time.now.to_f
        rv += 1E6 if rv == initial
        rv
      end
  end
end