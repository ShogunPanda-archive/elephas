# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Elephas
  # This is the main class of the framework. Use only this class to access the cache.
  #
  # @attribute backend
  #   @return [Backend] The backend used for the caching.
  # @attribute prefix
  #   @return [String] The default prefix for cache entries.
  class Cache
    attr_accessor :backend
    attr_accessor :prefix

    # Initialize the cache.
    #
    # @param backend [Backends::Base] The backend to use. By default uses an Hash backend.
    def initialize(backend = nil)
      @backend = backend || Elephas::Backends::Hash.new
      @prefix = "elephas-#{::Elephas::Version::STRING}-cache"
    end

    # This is the main method of the framework.
    #
    # It tries reading a key from the cache.
    #
    # If it doesn't find it, it uses the provided block (which receives options as argument) to compute its value and then store it into the cache for later usages.
    #
    # ```ruby
    # cache = Elephas::Cache.new(Elephas::Backends::Hash.new)
    #
    # value = cache.use("KEY") do |options|
    #   "VALUE"
    # end
    #
    # value
    # # => "VALUE"
    #
    # value = cache.use("KEY") do |options|
    #   "ANOTHER VALUE"
    # end
    #
    # value
    # # => "VALUE"
    # ```
    #
    # @param key [String] The key to lookup.
    # @param options [Hash] A list of options for managing this key.
    # @param block [Proc] An optional block to run to compute the value for the key if nothing is found.
    # @return [Object|Entry] The found or newly-set value associated to the key.
    # @see .setup_options
    def use(key, options = {}, &block)
      rv = nil

      # Get options
      options = setup_options(options, key)

      # Check if the storage has the value (if we don't have to skip the cache)
      rv = choose_backend(options).read(options[:hash]) if options[:force] == false && options[:ttl] > 0
      rv = compute_value(options, &block) if rv.nil? && block # Try to compute the value from the block

      # Return value
      options[:as_entry] ? rv : rv.value.dup
    end

    # Reads a value from the cache.
    #
    # @param key [String] The key to lookup.
    # @param backend [Backends::Base|NilClass] The backend to use. Defaults to the current backend.
    # @return [Object|NilClass] The read value or `nil`.
    def read(key, backend = nil)
      choose_backend({backend: backend}).read(key)
    end

    # Writes a value to the cache.
    #
    # @param key [String] The key to associate the value with.
    # @param value [Object] The value to write. Setting a value to `nil` **doesn't** mean *deleting* the value.
    # @param options [Hash] A list of options for writing.
    # @see .setup_options
    # @return [Object] The value itself.
    def write(key, value, options = {})
      choose_backend(options).write(key, value, setup_options(options, key))
    end

    # Deletes a value from the cache.
    #
    # @param key [String] The key to delete.
    # @param backend [Backends::Base|NilClass] The backend to use. Defaults to the current backend.
    # @return [Boolean] `true` if the key was in the cache, `false` otherwise.
    def delete(key, backend = nil)
      choose_backend({backend: backend}).delete(key)
    end

    # Checks if a key exists in the cache.
    #
    # @param key [String] The key to lookup.
    # @param backend [Backends::Base|NilClass] The backend to use. Defaults to the current backend.
    # @return [Boolean] `true` if the key is in the cache, `false` otherwise.
    def exists?(key, backend = nil)
      choose_backend({backend: backend}).exists?(key)
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
      options = {ttl: 1.hour * 1000, force: false, as_entry: false}.merge(options.ensure_hash)

      # Sanitize options.
      options = sanitize_options(options, key)

      # Wrap the final key to ensure we don't have colliding namespaces.
      options[:complete_key] ||= "#{options[:prefix]}[#{options[:key]}]"

      # Compute the hash key used for referencing this value.
      options[:hash] ||= ::Elephas::Entry.hashify_key(options[:complete_key])

      options
    end

    private
      # Computes a new value and saves it to the cache.
      #
      # @param options [Hash] A list of options for managing the value.
      # @param block [Proc] The block to run to compute the value.
      # @return [Object|Entry] The new value.
      def compute_value(options, &block)
        rv = block.call(options)
        rv = ::Elephas::Entry.ensure(rv, options[:complete_key], options) # Make sure is an entry
        write(rv.hash, rv, options) if !rv.value.nil? && options[:ttl] > 0 # We have a value and we have to store it
        rv
      end

      # Sanitizes options for safe usage.
      #
      # @param options [Object] An initial setup.
      # @param key [String] The key to associate to this options.
      # @return [Hash] An options hash.
      def sanitize_options(options, key)
        options[:key] ||= key
        options[:ttl] == options[:ttl].blank? ? 1.hour * 1000 : [options[:ttl].to_integer, 0].max
        options[:force] = options[:force].to_boolean
        options[:prefix] = options[:prefix].present? ? options[:prefix] : prefix

        options
      end

      # Choose a backend to use.
      #
      # @param options [Backends::Base|Hash] The backend to use. Defaults to the current backend.
      def choose_backend(options)
        backend = options.ensure_hash(:symbols)[:backend]
        backend.is_a?(Elephas::Backends::Base) ? backend : self.backend
      end
  end
end