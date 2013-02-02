# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Providers::Hash do
  subject { ::Elephas::Providers::Hash.new }
  let!(:value) { subject.write("KEY", ::Elephas::Entry.ensure("VALUE", "KEY", {ttl: 3600})) }

  describe "#initialize" do
    it "should create a store with an empty hash" do
      expect(::Elephas::Providers::Hash.new.data).to eq({})
    end

    it "should create a store with an given hash" do
      expect(::Elephas::Providers::Hash.new({a: :b}).data).to eq({a: :b})
    end

    it "should ensure that the store is an Hash" do
      expect(::Elephas::Providers::Hash.new(nil).data).to eq({})
      expect(::Elephas::Providers::Hash.new("INVALID").data).to eq({})
    end
  end

  describe "#read" do
    it "fetch data from the hash" do
      expect(subject.read("KEY")).to be_a(::Elephas::Entry)
      expect(subject.read("KEY").value).to eq("VALUE")
    end

    it "return nil for missing or expired values" do
      subject.data["KEY"].updated_at = Time.now.to_f - 3700

      expect(subject.read("KEY")).to be_nil
      expect(subject.read("INVALID")).to be_nil
    end
  end

  describe "#write" do
    it "should save data to the hash" do
      expect(subject.data["KEY"]).to be_a(::Elephas::Entry)
      expect(subject.data["KEY"].key).to eq("KEY")
      expect(subject.data["KEY"].value).to eq("VALUE")
    end

    it "should save data and update TTL" do
      updated_at = value.updated_at

      expect(subject.write("KEY", value)).to eq(value)
      expect(value.updated_at).not_to eq(updated_at)
    end
  end

  describe "#delete" do
    it "should delete a stored value and return true" do
      expect(subject.delete("KEY")).to be_true
      expect(subject.data["KEY"]).to be_nil
    end

    it "should return false if the value doesn't exists" do
      expect(subject.delete("INVALID")).to be_false
    end
  end

  describe "#exists?" do
    it "returns true for valid keys" do
      expect(subject.exists?("KEY")).to be_true
    end

    it "returns false for invalid or expired keys" do
      subject.data["KEY"].updated_at = Time.now.to_f - 3700

      expect(subject.exists?("KEY")).to be_false
      expect(subject.exists?("INVALID")).to be_false
    end
  end
end