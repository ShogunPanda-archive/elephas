# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require "digest/sha2"
Lazier.load!("boolean", "math", "object")

require "elephas/version" if !defined?(Elephas::Version)
require "elephas/entry"
require "elephas/provider"
require "elephas/providers/hash"
require "elephas/providers/ruby_on_rails"
require "elephas/cache"

Elephas::Cache.provider = defined?(Rails) ? Elephas::Providers::RubyOnRails.new : Elephas::Providers::Hash.new