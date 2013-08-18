# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  module Backends
    # This is a simple backend, which uses an hash for storing the values.
    #
    # @attribute data
    #   @return [HashWithIndifferentAccess] The internal hash used by the backend.
    class Hash < Base
      attr_accessor :data

      # Initialize the backend.
      #
      # @param data [Hash] The initial data stored.
      def initialize(data = nil)
        @data = data.ensure_hash(:indifferent)
      end

      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Entry|NilClass] The read value or `nil`.
      def read(key)
        exists?(key) ? @data[key] : nil
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
        @data[key] = entry
        entry
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        rv = @data.has_key?(key)
        @data.delete(key)
        rv
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        @data.has_key?(key) && @data[key].valid?(self)
      end
    end
  end
end