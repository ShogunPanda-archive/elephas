# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # This module hosts all the storage system for the caches.
  module Backends
    # The a base backend. All data-related methods must be overriden.
    class Base
      include Lazier::I18n

      # Reads a value from the cache.
      #
      # @param key [String] The key to lookup.
      # @return [Entry|NilClass] The read value or `nil`.
      def read(key)
        unimplemented
      end

      # Writes a value to the cache.
      #
      # @param key [String] The key to associate the value with.
      # @param value [Object] The value to write. Setting a value to `nil` **doesn't** mean *deleting* the value.
      # @param options [Hash] A list of options for writing.
      # @see Elephas::Cache.setup_options
      # @return [Object] The value itself.
      def write(key, value, options = {})
        unimplemented
      end

      # Deletes a value from the cache.
      #
      # @param key [String] The key to delete.
      # @return [TrueClass|FalseClass] `true` if the key was in the cache, `false` otherwise.
      def delete(key)
        unimplemented
      end

      # Checks if a key exists in the cache.
      #
      # @param key [String] The key to lookup.
      # @return [TrueClass|FalseClass] `true` if the key is in the cache, `false` otherwise.
      def exists?(key)
        unimplemented
      end

      # Returns the current time for comparing with entries TTL.
      #
      # @return [Object] A representation of the current time.
      def now
        ::Time.now.to_f
      end

      private
        # Marks a method as unimplemented.
        def unimplemented
          i18n_setup(:elephas, ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../../locales/")) if !@i18n
          raise ArgumentError.new(i18n.unimplemented)
        end
    end
  end
end