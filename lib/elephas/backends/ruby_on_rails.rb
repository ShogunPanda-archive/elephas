# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  module Backends
    # This is a Ruby on Rails backend, which uses Rails.cache.
    class RubyOnRails < Base
      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Entry|NilClass] The read value or `nil`.
      def read(key)
        exists?(key) ? Rails.cache.read(key) : nil
      end

      # Writes a value to the cache.
      #
      # @param key [String] The key to associate the value with.
      # @param value [Object] The value to write. **Setting a value to `nil` **doesn't** mean *deleting* the value.
      # @param options [Hash] A list of options for writing.
      # @see Elephas::Cache.setup_options
      # @return [Object] The value itself.
      def write(key, value, options = {})
        entry = ::Elephas::Entry.ensure(value, key, options)
        entry.refresh
        Rails.cache.write(key, entry, expires_in: entry.ttl)
        entry
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        rv = Rails.cache.exist?(key)
        Rails.cache.delete(key)
        rv
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        Rails.cache.exist?(key) && Rails.cache.read(key).valid?(self)
      end
    end
  end
end