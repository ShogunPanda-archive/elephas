# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Cache do
  pending ".use" do

  end

  describe ".read" do
    it "should be forwarded to the provider" do
      Elephas::Cache.provider.should_receive(:read)
      Elephas::Cache.read("KEY")
    end
  end

  describe ".write" do
    it "should be forwarded to the provider" do
      Elephas::Cache.provider.should_receive(:write)
      Elephas::Cache.write("KEY", "VALUE")
    end
  end

  describe ".delete" do
    it "should be forwarded to the provider" do
      Elephas::Cache.provider.should_receive(:delete)
      Elephas::Cache.delete("KEY")
    end
  end

  describe ".exists?" do
    it "should be forwarded to the provider" do
      Elephas::Cache.provider.should_receive(:exists?)
      Elephas::Cache.exists?("KEY")
    end
  end
end