# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Cache do
  let(:entry) { ::Elephas::Entry.ensure("VALUE", ::Elephas::Cache.new(nil).prefix + "[KEY]", {ttl: 3600}) }
  let(:reference) { ::Elephas::Cache.new(::Elephas::Backends::Hash.new) }

  describe ".use" do
    it "should use the provider for reading the value" do
      expect(reference.backend).to receive(:read)
      reference.use("KEY") do "VALUE" end
    end

    it "should skip the provider if requested to" do
      reference.use("KEY", {ttl: 0}) do "VALUE" end
      expect(reference.backend).not_to receive(:read)
      reference.use("KEY", {force: true}) do "VALUE" end
      expect(reference.backend).not_to receive(:read)
    end

    it "should use the block for value computation" do
      expect{ reference.use("KEY") do raise ArgumentError end }.to raise_error(ArgumentError)
    end

    it "should not use the block if the value is valid" do
      reference.use("KEY") do entry end
      expect{ reference.use("KEY") do raise ArgumentError end }.not_to raise_error
    end

    it "should store the value in the cache" do
      reference.use("KEY") do entry end
      expect(reference.backend.read(entry.hash)).to eq(entry)
    end

    it "should return the entire entry or only the value" do
      reference.use("KEY") do "VALUE" end

      expect(reference.use("KEY")).to eq("VALUE")
      value = reference.use("KEY", {as_entry: true})
      expect(value).to be_a(::Elephas::Entry)
      expect(value.value).to eq("VALUE")
    end
  end

  describe ".read" do
    it "should be forwarded to the provider" do
      expect(reference.backend).to receive(:read)
      reference.read("KEY")
    end
  end

  describe ".write" do
    it "should be forwarded to the provider" do
      expect(reference.backend).to receive(:write)
      reference.write("KEY", "VALUE")
    end
  end

  describe ".delete" do
    it "should be forwarded to the provider" do
      expect(reference.backend).to receive(:delete)
      reference.delete("KEY")
    end
  end

  describe ".exists?" do
    it "should be forwarded to the provider" do
      expect(reference.backend).to receive(:exists?)
      reference.exists?("KEY")
    end
  end

  describe "setup_options" do
    it "should set good defaults for options" do
      hashes = {
        base: ::Elephas::Entry.hashify_key("#{reference.prefix}[KEY]"),
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
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 2.hour, force: false, as_entry: false, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: true, as_entry: false, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: true, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: hashes[:base]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: "prefix", complete_key: "prefix[KEY]", hash: hashes[:alternative]},
        {key: "KEY", ttl: 1.hour * 1000, force: false, as_entry: false, prefix: reference.prefix, complete_key: "#{reference.prefix}[KEY]", hash: "hash"}
      ]

      options_hashes.each_with_index do |options, i|
        expect(reference.setup_options(options, "KEY")).to eq(reference_hashes[i])
      end
    end
  end
end