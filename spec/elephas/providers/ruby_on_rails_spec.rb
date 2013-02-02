# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Providers::RubyOnRails do
  class TempRailsCache < Hash # This class simulate the presence of Rails
    def read(key)
      self[key]
    end

    def write(key, value, options = {})
      self[key] = value
    end

    def exist?(key)
      self.has_key?(key)
    end
  end

  class Rails
    def self.cache
      @cache ||= TempRailsCache.new
    end
  end

  subject { ::Elephas::Providers::RubyOnRails.new }
  let!(:value) { subject.write("KEY", ::Elephas::Entry.ensure("VALUE", "KEY", {ttl: 3600})) }

  describe "#read" do
    it "fetch data from the cache" do
      expect(subject.read("KEY")).to be_a(::Elephas::Entry)
      expect(subject.read("KEY").value).to eq("VALUE")
    end

    it "return nil for missing or expired values" do
      Rails.cache.read("KEY").updated_at = Time.now.to_f - 3700

      expect(subject.read("KEY")).to be_nil
      expect(subject.read("INVALID")).to be_nil
    end
  end

  describe "#write" do
    it "should save data to the hash" do
      expect(Rails.cache.read("KEY")).to be_a(::Elephas::Entry)
      expect(Rails.cache.read("KEY").key).to eq("KEY")
      expect(Rails.cache.read("KEY").value).to eq("VALUE")
    end

    it "should save data and update TTL" do
      value = Rails.cache.read("KEY")
      updated_at = value.updated_at

      expect(subject.write("KEY", value)).to eq(value)
      expect(value.updated_at).not_to eq(updated_at)
    end
  end

  describe "#delete" do
    it "should delete a stored value and return true" do
      expect(subject.delete("KEY")).to be_true
      expect(Rails.cache.read("KEY")).to be_nil
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
      Rails.cache.read("KEY").updated_at = Time.now.to_f - 3700

      expect(subject.exists?("KEY")).to be_false
      expect(subject.exists?("INVALID")).to be_false
    end
  end
end