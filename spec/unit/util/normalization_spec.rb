# encoding: utf-8

require 'spec_helper'
require 'facter/util/normalization'

describe Facter::Util::Normalization do

  subject { described_class }

  describe "validating strings" do
    describe "and string encoding is supported", :if => String.instance_methods.include?(:encoding) do
      it "accepts strings that are ASCII and match their encoding and converts them to UTF-8" do
        str = "ASCII".encode(Encoding::ASCII)
        subject.normalize(str)
        expect(str.encoding).to eq(Encoding::UTF_8)
      end

      it "accepts strings that are UTF-8 and match their encoding" do
        str = "let's make a ☃!".encode(Encoding::UTF_8)
        subject.normalize(str)
      end

      it "converts valid non UTF-8 strings to UTF-8" do
        str = "let's make a ☃!".encode(Encoding::UTF_16LE)
        subject.normalize(str)
        expect(str.encoding).to eq(Encoding::UTF_8)
      end

      it "rejects strings that are not UTF-8 and do not match their claimed encoding" do
        invalid_shift_jis = "\xFF\x5C!".force_encoding(Encoding::SHIFT_JIS)
        expect {
          subject.normalize(invalid_shift_jis)
        }.to raise_error(Facter::Util::Normalization::NormalizationError, /String encoding Shift_JIS is not UTF-8 and could not be converted to UTF-8/)
      end

      it "rejects strings that claim to be UTF-8 encoded but aren't" do
        str = "\255ay!".force_encoding(Encoding::UTF_8)
        expect {
          subject.normalize(str)
        }.to raise_error(Facter::Util::Normalization::NormalizationError, /String.*doesn't match the reported encoding UTF-8/)
      end
    end

    describe "and string encoding is not supported", :unless => String.instance_methods.include?(:encoding) do
      it "accepts strings that are UTF-8 and match their encoding" do
        str = "let's make a ☃!"
        subject.normalize(str)
      end

      it "rejects strings that are not UTF-8" do
        str = "let's make a \255\255\255!"
        expect {
          subject.normalize(str)
        }.to raise_error(Facter::Util::Normalization::NormalizationError, /String .* is not valid UTF-8/)
      end
    end
  end

  describe "validating arrays" do
    it "normalizes each element in the array" do
      arr = ['first', 'second', ['third', 'fourth']]

      subject.expects(:normalize).with('first')
      subject.expects(:normalize).with('second')
      subject.expects(:normalize).with(['third', 'fourth'])

      subject.normalize_array(arr)
    end
  end

  describe "validating hashes" do
    it "normalizes each element in the array" do
      hsh = {'first' => 'second', 'third' => ['fourth', 'fifth']}

      subject.expects(:normalize).with('first')
      subject.expects(:normalize).with('second')
      subject.expects(:normalize).with('third')
      subject.expects(:normalize).with(['fourth', 'fifth'])

      subject.normalize_hash(hsh)
    end
  end

  [1, 1.0, true, false, nil].each do |val|
    it "accepts #{val.inspect}:#{val.class}" do
      subject.normalize(val)
    end
  end

  [:sym, Object.new, Set.new].each do |val|
    it "rejects #{val.inspect}:#{val.class}" do
      expect {
        subject.normalize(val)
      }.to raise_error(Facter::Util::Normalization::NormalizationError, /Expected .*but was #{val.class}/ )
    end
  end
end

