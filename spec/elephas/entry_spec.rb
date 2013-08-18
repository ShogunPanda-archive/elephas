# encoding: utf-8
#
# This file is part of the elephas gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Elephas::Entry do
  let(:backend) { ::Elephas::Backends::Hash.new }
  subject { ::Elephas::Entry.new("KEY", "VALUE") }

  describe "#initialize" do
    it "should initialize with good defaults" do
      allow(::Time).to receive(:now).and_return(123.456)
      expect(subject.key).to eq("KEY")
      expect(subject.value).to eq("VALUE")
      expect(subject.hash).to eq("5ca24005b740717ba4f3f6bc48a230700e68c2a4b11ecedb96f169f4efaf1f21")
      expect(subject.ttl).to eq(360000)
      expect(subject.updated_at).to eq(123.456)

      allow(::Time).to receive(:now).and_return(123.789)
      other = ::Elephas::Entry.new("KEY 1", "VALUE 1", "HASH", 7200)
      expect(other.key).to eq("KEY 1")
      expect(other.value).to eq("VALUE 1")
      expect(other.hash).to eq("HASH")
      expect(other.ttl).to eq(7200)
      expect(other.updated_at).to eq(123.789)
    end
  end

  describe "#refresh" do
    before(:each) do
      allow(::Time).to receive(:now).and_return(123.123)
    end

    it "should update the updated_at field" do
      expect(subject.updated_at).to eq(123.123)
      allow(::Time).to receive(:now).and_return(456.456)
      subject.refresh
      expect(subject.updated_at).to eq(456.456)
    end

    it "should save to the cache" do
      expect(backend.read(subject.hash)).not_to eq(subject)
      subject.refresh(true, backend)
      expect(backend.read(subject.hash)).to eq(subject)
    end
  end

  describe "#valid?" do
    before(:each) do
      allow(::Time).to receive(:now).and_return(100)
    end

    it "should return true if the ttl is still valid" do
      allow(::Time).to receive(:now).and_return(1000)
      expect(subject.valid?(backend)).to be_true
    end

    it "should return true if the ttl has expired" do
      allow(::Time).to receive(:now).and_return(10000)
      subject.updated_at = 1000
      expect(subject.valid?(backend)).to be_false
    end
  end

  describe "==" do
    it "should correctly compare with other entries" do
      expect(subject == subject).to be_true
      expect(subject == ::Elephas::Entry.new("KEY", "VALUE")).to be_true
      expect(subject == ::Elephas::Entry.new("KEY", "VALUE 1")).to be_false
      expect(subject == ::Elephas::Entry.new("KEY 1", "VALUE")).to be_false
      expect(subject == ::Elephas::Entry.new("KEY", "VALUE", "HASH")).to be_false
    end

    it "should return false for other type" do
      expect(subject == nil).to be_false
      expect(subject == "A").to be_false
    end
  end

  describe ".hashify_key" do
    it "should compute a good hash" do
      expect(::Elephas::Entry.hashify_key("HASH 1")).to eq("88e1f3572122e2605c1fab09efa8d4e99f5a064ae0230ca0aeced839796aba35")
      expect(::Elephas::Entry.hashify_key("HASH 2")).to eq("38589cee32e00f700cf958dfe98f17d6da231700c41586e3c32b00314bb3cb58")
    end
  end

  describe ".ensure" do
    it "should wrap the value" do
      expect(::Elephas::Entry.ensure(nil, "KEY 1")).to eq(::Elephas::Entry.new("KEY 1", nil))
      expect(::Elephas::Entry.ensure("A", "KEY 2")).to eq(::Elephas::Entry.new("KEY 2", "A"))
      expect(::Elephas::Entry.ensure([], "KEY 3")).to eq(::Elephas::Entry.new("KEY 3", []))
    end

    it "should not alter Entry objects" do
      expect(::Elephas::Entry.ensure(subject, "ANOTHER KEY")).to eq(subject)
    end
  end
end