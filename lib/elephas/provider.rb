# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # This module hosts all the storage system for the caches.
  module Providers

    # The base provider, with all methods a valid provider should override.
    module Base
      extend ActiveSupport::Concern

      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Entry|NilClass] The read value or `nil`.
      def read(key)
        raise ArgumentError.new("A Elephas::Providers subclass should override this module.")
      end

      # Writes a value to the cache.
      #
      # @param key [String] The key to associate the value with.
      # @param value [Object] The value to write. **Setting a value to `nil` doesn't mean *deleting* the value.
      # @param options [Hash] A list of options for writing. @see Elephas::Cache.write
      # @return [Object] The value itself.
      def write(key, value, options = {})
        raise ArgumentError.new("A Elephas::Providers subclass should override this module.")
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [TrueClass|FalseClass] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        raise ArgumentError.new("A Elephas::Providers subclass should override this module.")
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [TrueClass|FalseClass] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        raise ArgumentError.new("A Elephas::Providers subclass should override this module.")
      end

      # Returns the current time for comparing with entries TTL.
      #
      # @return [Object] A representation of the current time.
      def now
        ::Time.now.to_f
      end
    end
  end
end