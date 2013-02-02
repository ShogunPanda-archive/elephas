# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe ::Elephas::Cache do
  let(:entry) { ::Elephas::Entry.ensure("VALUE", ::Elephas::Cache.default_prefix + "[KEY]", {ttl: 3600}) }

  describe ".use" do
    before(:each) do
      ::Elephas::Cache.provider = Elephas::Providers::Hash.new
    end

    it "should use the provider for reading the value" do
      ::Elephas::Cache.provider.should_receive(:read)
      ::Elephas::Cache.use("KEY") do "VALUE" end
    end

    it "should skip the provider if requested to" do
      ::Elephas::Cache.use("KEY", {ttl: 0}) do "VALUE" end
      ::Elephas::Cache.provider.should_not_receive(:read)
      ::Elephas::Cache.use("KEY", {force: true}) do "VALUE" end
      ::Elephas::Cache.provider.should_not_receive(:read)
    end

    it "should use the block for value computation" do
      expect{ ::Elephas::Cache.use("KEY") do raise ArgumentError end }.to raise_error(ArgumentError)
    end

    it "should not use the block if the value is valid" do
      ::Elephas::Cache.use("KEY") do entry end
      expect{ ::Elephas::Cache.use("KEY") do raise ArgumentError end }.not_to raise_error(ArgumentError)
    end

    it "should store the value in the cache" do
      ::Elephas::Cache.use("KEY") do entry end
      expect(::Elephas::Cache.provider.read(entry.hash)).to eq(entry)
    end

    it "should return the entire entry or only the value" do
      ::Elephas::Cache.use("KEY") do "VALUE" end

      expect(::Elephas::Cache.use("KEY")).to eq("VALUE")
      value = ::Elephas::Cache.use("KEY", {as_entry: true})
      expect(value).to be_a(::Elephas::Entry)
      expect(value.value).to eq("VALUE")
    end
  end

  describe ".read" do
    it "should be forwarded to the provider" do
      ::Elephas::Cache.provider.should_receive(:read)
      ::Elephas::Cache.read("KEY")
    end
  end

  describe ".write" do
    it "should be forwarded to the provider" do
      ::Elephas::Cache.provider.should_receive(:write)
      ::Elephas::Cache.write("KEY", "VALUE")
    end
  end

  describe ".delete" do
    it "should be forwarded to the provider" do
      ::Elephas::Cache.provider.should_receive(:delete)
      ::Elephas::Cache.delete("KEY")
    end
  end

  describe ".exists?" do
    it "should be forwarded to the provider" do
      ::Elephas::Cache.provider.should_receive(:exists?)
      ::Elephas::Cache.exists?("KEY")
    end
  end

  describe "setup_options" do
    it "should set good defaults for options" do
      hashes = {
        base: ::Elephas::Entry.hashify_key("#{::Elephas::Cache.default_prefix}[KEY]"),
        alternative: ::Elephas::Entry.hashify_key("prefix[KEY]")
      }
      
      options_hashes = [
        nil,
        "A",
        {ttl: 2.hour},
        {force: true},
        {as_entry: true},
        {prefix: "prefix", hash: hashes[:alternative]},
        {hash: "hash"}
      ]

      reference_hashes = [
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 2.hour, force: false, as_entry: false, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: true, as_entry: false, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: true, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: "prefix", complete_key: "prefix[KEY]", hash: hashes[:alternative]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: ::Elephas::Cache.default_prefix, complete_key: "#{::Elephas::Cache.default_prefix}[KEY]", hash: "hash"}
      ]

      options_hashes.each_with_index do |options, i|
        expect(::Elephas::Cache.setup_options(options, "KEY")).to eq(reference_hashes[i])
      end
    end
  end
end