# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# This is the top level module for elephas gem.
module Elephas
  # The current version of elephas, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 0

    # The minor version.
    MINOR = 1

    # The patch version.
    PATCH = 0

    # The current version of elephas.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
