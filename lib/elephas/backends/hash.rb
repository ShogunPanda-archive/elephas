# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  module Backends
    # This is a simple backend, which uses an hash for storing the values.
    #
    # @attribute data
    #   @return [Hash] The internal hash used by the backend.
    class Hash < Base
      attr_accessor :data

      # Initialize the backend.
      #
      # @param data [Hash] The initial data stored.
      def initialize(data = nil)
        @data = data && data.is_a?(::Hash) ? data : {}
      end

      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Entry|NilClass] The read value or `nil`.
      def read(key)
        self.exists?(key) ? @data[key.ensure_string] : nil
      end

      # Writes a value to the cache.
      #
      # @param key [String] The key to associate the value with.
      # @param value [Object] The value to write. Setting a value to `nil` **doesn't** mean *deleting* the value.
      # @param options [Hash] A list of options for writing.
      # @see Elephas::Cache.setup_options
      # @return [Object] The value itself.
      def write(key, value, options = {})
        entry = ::Elephas::Entry.ensure(value, key, options)
        entry.refresh
        @data[key.ensure_string] = entry
        entry
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        key = key.ensure_string
        rv = @data.has_key?(key)
        @data.delete(key)
        rv
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        key = key.ensure_string
        @data.has_key?(key) && @data[key].valid?(self)
      end
    end
  end
end