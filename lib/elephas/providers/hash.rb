# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  module Providers
    # This is a simple providers, which uses an hash for storing the values.
    class Hash
      include Elephas::Providers::Base

      # The internal hash used by the provider.
      attr_accessor :data

      # Initialize the provider
      # @param The initial data stored.
      def initialize(data = nil)
        data = {} if !data || !data.is_a?(::Hash)
        @data = data
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
      # @param value [Object] The value to write. **Setting a value to `nil` doesn't mean *deleting* the value.
      # @param options [Hash] A list of options for writing. @see Elephas::Cache.write
      # @return [Object] The value itself.
      def write(key, value, options = {})
        fvalue = ::Elephas::Entry.ensure(value, key, options)
        fvalue.refresh
        @data[key.ensure_string] = fvalue
        value
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        fkey = key.ensure_string
        rv = @data.has_key?(fkey)
        @data.delete(fkey)
        rv
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        fkey = key.ensure_string
        @data.has_key?(fkey) && @data[fkey].valid?
      end
    end
  end
end