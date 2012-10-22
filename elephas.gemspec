# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/elephas/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "elephas"
  gem.version = Elephas::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/elephas"
  gem.summary = %q{A storage agnostic caching framework.}
  gem.description = %q{A storage agnostic caching framework.}
  gem.rubyforge_project = "elephas"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("lazier", "~> 1.0")

  gem.add_development_dependency("rspec", "~> 2.11.0")
  gem.add_development_dependency("rake", "~> 0.9.0")
  gem.add_development_dependency("simplecov", "~> 0.7.0")
  gem.add_development_dependency("pry", ">= 0")
  gem.add_development_dependency("yard", "~> 0.8.0")
  gem.add_development_dependency("redcarpet", "~> 2.2.2")
  gem.add_development_dependency("github-markup", "~> 0.7.0")
end
