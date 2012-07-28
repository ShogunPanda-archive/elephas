# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # This is the main class of the framework. Use only this class to access the cache.
  class Cache
    class << self
      # The provider used for the caching.
      attr_accessor :provider

      # This is the main method of the framework.
      # It tries reading a key from the cache. If it doesn't find it, it uses the provided block to compute its value and then store it into the cache for later usages.
      #
      # @param key [String] The key to lookup.
      # @return [Object|Entry] The found or newly-set value associated to the key.
      def use(key, options = {})
        rv = nil

        # Get options
        options = {} if !options.is_a?(::Hash)
        options = {:ttl => 1.hour, :force => false, :as_entry => false}.merge(options)
        options[:ttl] == [options[:ttl].to_integer, 0].max
        options[:force] = options[:force].to_boolean
        options[:prefix] = options[:prefix].present? ? options[:prefix] : "elephas-#{::Elephas::Version::STRING}-cache"

        # Wrap the final key to ensure we don't have colliding namespaces.
        fkey = "#{options[:prefix]}[#{key}]"

        # Compute the hash key used for referencing this value
        options[:hash] = options[:hash] || ::Elephas::Entry.hashify_key(fkey.ensure_string)

        # Check if the storage has the value (if we don't have to skip the cache)
        rv = self.provider.read(options[:hash]) if options[:force] == false && options[:ttl] > 0

        if rv.nil? && block_given? then # Try to compute the value from the block
          rv = yield(key, options)

          if rv && options[:ttl] > 0 then # We have a value and we have to store it
            rv = ::Elephas::Entry.ensure(rv, key, options) # Make sure is an entry
            Elephas::Cache.write(fkey, value, options)
          end
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
      # TODO: Insert options documentation.
      # @return [Object] The value itself.
      def write(key, value, options = {})
        # TODO: Handle options

        self.provider.write(key, value, options)
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [TrueClass|FalseClass] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        self.provider.delete(key)
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [TrueClass|FalseClass] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        self.provider.exists?(key)
      end
    end
  end
end