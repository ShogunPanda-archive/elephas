# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # This is the main class of the framework. Use only this class to access the cache.
  class Cache
    # @attr provider [Provider] The provider used for the caching.
    class << self
      attr_accessor :provider

      # This is the main method of the framework.
      #
      # It tries reading a key from the cache.
      #
      # If it doesn't find it, it uses the provided block (which receives options as argument) to compute its value and then store it into the cache for later usages.
      #
      # ```ruby
      # value = Elephas::Cache.use("KEY") do |options|
      #   "VALUE"
      # end
      #
      # value
      # # => "VALUE"
      #
      # value = Elephas::Cache.use("KEY") do |options|
      #   "ANOTHER VALUE"
      # end
      #
      # value
      # # => "VALUE"
      # ```
      #
      # @param key [String] The key to lookup.
      # @return [Object|Entry] The found or newly-set value associated to the key.
      # @see
      def use(key, options = {})
        rv = nil

        # Get options
        options = self.setup_options(options, key)

        # Check if the storage has the value (if we don't have to skip the cache)
        rv = self.provider.read(options[:hash]) if options[:force] == false && options[:ttl] > 0

        if rv.nil? && block_given? then # Try to compute the value from the block
          rv = yield(options)
          rv = ::Elephas::Entry.ensure(rv, options[:complete_key], options) # Make sure is an entry
          Elephas::Cache.write(rv.hash, rv, options) if !rv.value.nil? && options[:ttl] > 0 # We have a value and we have to store it
        end

        # Return value
        options[:as_entry] ? rv : rv.value.dup
      end

      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Object|NilClass] The read value or `nil`.
      def read(key)
        self.provider.read(key)
      end

      # Writes a value to the cache.
      #
      # @param key [String] The key to associate the value with.
      # @param value [Object] The value to write. Setting a value to `nil` **doesn't** mean *deleting* the value.
      # @param options [Hash] A list of options for writing.
      # @see .setup_options
      # @return [Object] The value itself.
      def write(key, value, options = {})
        self.provider.write(key, value, self.setup_options(options, key))
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        self.provider.delete(key)
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        self.provider.exists?(key)
      end

      # Returns the default prefix for cache entries.
      #
      # @return [String] The default prefix for cache entries.
      def default_prefix
        "elephas-#{::Elephas::Version::STRING}-cache"
      end

      # Setups options for use into the framework.
      # Valid options are:
      #
      #   * **:ttl**: The TTL (time to live, in milliseconds) of the entry. It means how long will the value stay in cache. Setting it to 0 or less means never cache the entry.
      #   * **:force**: Setting it to `true` will always skip the cache.
      #   * **:key**: The key associated to this value. **You should never set this option directly.**
      #   * **:prefix**: The prefix used in cache. This is used to avoid conflicts with other caching frameworks.
      #   * **:complete_key**: The complete key used for computing the hash. By default is concatenation of `:key` and `:prefix` options.
      #   * **:hash**: The hash used to store the key in the cache. Should be unique
      #   * **:as_entry**: In `Elephas::Cache.use`, setting this to `true` will return the entire `Entry` object rather than the value only.
      #
      # @param options [Object] An initial setup.
      # @param key [String] The key to associate to this options.
      # @return [Hash] An options hash.
      def setup_options(options, key)
        options = {} if !options.is_a?(::Hash)
        options = {ttl: 1.hour * 1000, force: false, as_entry: false}.merge(options)
        options[:key] ||= key.ensure_string
        options[:ttl] == options[:ttl].blank? ? 1.hour * 1000 : [options[:ttl].to_integer, 0].max
        options[:force] = options[:force].to_boolean
        options[:prefix] = options[:prefix].present? ? options[:prefix] : "elephas-#{::Elephas::Version::STRING}-cache"

        # Wrap the final key to ensure we don't have colliding namespaces.
        options[:complete_key] ||= "#{options[:prefix]}[#{options[:key]}]"

        # Compute the hash key used for referencing this value
        options[:hash] ||= ::Elephas::Entry.hashify_key(options[:complete_key])

        options
      end
    end
  end
end