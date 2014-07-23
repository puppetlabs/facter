require 'spec_helper'
require 'facter/util/formatter'

describe Facter::Util::Formatter do
  describe "formatting as json" do
    it "formats the text as json when json is available", :if => Facter.json? do
      JSON.expects(:pretty_generate).with({"hello" => "world"}).returns(%Q({"hello": "world"}))
      expect(described_class.format_json({"hello" => "world"})).to eq %Q({"hello": "world"})
    end

    it "raises an error when JSON is not available" do
      Facter.stubs(:json?).returns false
      expect {
        described_class.format_json({"hello" => "world"})
      }.to raise_error(/'json' library is not present/)
    end
  end

  describe "formatting as yaml" do
    it "dumps the text as YAML" do
      expect(described_class.format_yaml({"hello" => "world"})).to match(/hello: world/)
    end
  end

  describe "formatting as plaintext" do
    it "formats a single string value without quotes" do
      expect(described_class.format_plaintext({"foo" => "bar"})).to eq "bar"
    end

    it "can return false:FalseClass as a single fact value" do
      expect(described_class.format_plaintext({"foo" => false})).to eq "false"
    end

    it "formats a structured value with #inspect" do
      value = ["bar"]
      value.expects(:inspect).returns %Q(["bar"])
      hash = {"foo" => value, "baz" => "quux"}
      expect(described_class.format_plaintext(hash)).to match(%Q([bar]))
    end

    it "formats multiple string values as key/value pairs" do
      hash = {"foo" => "bar", "baz" => "quux"}
      expect(described_class.format_plaintext(hash)).to match(/foo => bar/)
      expect(described_class.format_plaintext(hash)).to match(/baz => quux/)
    end

    it "formats multiple structured values with #inspect" do
      value = ["bar"]
      value.expects(:inspect).twice.returns %Q(["bar"])
      hash = {"foo" => value, "baz" => "quux"}
      expect(described_class.format_plaintext(hash)).to match(/foo => \["bar"\]/)
      expect(described_class.format_plaintext(hash)).to match(/baz => quux/)
    end
  end
end
