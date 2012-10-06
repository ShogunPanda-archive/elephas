# elephas

[![Build Status](https://secure.travis-ci.org/ShogunPanda/elephas.png?branch=master)](http://travis-ci.org/ShogunPanda/elephas)
[![Dependency Status](https://gemnasium.com/ShogunPanda/elephas.png?travis)](https://gemnasium.com/ShogunPanda/elephas)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ShogunPanda/elephas)

A storage agnostic caching framework.

http://github.com/ShogunPanda/elephas

## Usage

The usage of the framework is really simple.

At first you have to setup a provider (that is, a storage) for the Elephas. By default it uses an internal hash, and also Rails is supported.

```ruby
Elephas::Cache.provider = Elephas::Providers::RubyOnRails.new
```

After that, you can query the framework for a value use the `use` method.

You should also pass a block to the method, so that the framework use that for computing the value of the cache entry.

```ruby
value = Elephas::Cache.use("KEY") do |options|
  "VALUE"
end
# => "VALUE"
```

The next time you issue this call, the block won't be called.

The block takes an argument, which contains all the options for the entry.

You can see ``Elephas::Cache.setup_options`` documentation to see what options are supported.

For now, you just have to know that you can set the ```:ttl``` option to specify how long the value will stay in the cache (in milliseconds). Setting it to a non-positive value means to never cache the value.

See documentation for more informations.

**You're done!**

## Contributing to elephas
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
