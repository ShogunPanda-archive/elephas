# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Providers::Base do
  class BaseProvider
    include Elephas::Providers::Base
  end

  let(:provider) { BaseProvider.new }

  describe ".read" do
    it "should raise an ArgumentError exception" do
      expect{ provider.read("KEY") }.to raise_error(ArgumentError)
    end
  end

  describe ".write" do
    it "should raise an ArgumentError exception" do
      expect{ provider.write("KEY", "VALUE") }.to raise_error(ArgumentError)
    end
  end

  describe ".delete" do
    it "should raise an ArgumentError exception" do
      expect{ provider.delete("KEY") }.to raise_error(ArgumentError)
    end
  end

  describe ".exists?" do
    it "should raise an ArgumentError exception" do
      expect{ provider.exists?("KEY") }.to raise_error(ArgumentError)
    end
  end

  describe "#now" do
    it "return a representation for the current time" do
      Time.stub(:now).and_return(123.456)
      expect(provider.now).to eq(Time.now.to_f)
    end
  end
end