# encoding: utf-8

require 'spec_helper'
require 'facter/util/validation'

describe Facter::Util::Validation do

  subject { Object.new.extend(described_class) }

  describe "validating strings" do
    describe "and string encoding is supported", :if => String.instance_methods.include?(:encoding) do
      it "accepts strings that are ASCII and match their encoding" do
        str = "ASCII".force_encoding(Encoding::ASCII)
        expect { subject.validate(str) }.to_not raise_error
      end

      it "accepts strings that are UTF-8 and match their encoding" do
        str = "let's make a ☃!".force_encoding(Encoding::UTF_8)
        expect { subject.validate(str) }.to_not raise_error
      end

      it "rejects strings that are not UTF-8 or ASCII" do
        str = 'ｵﾈ'.force_encoding(Encoding::SHIFT_JIS)
        expect {
          subject.validate(str)
        }.to raise_error(Facter::Util::Validation::ValidationError, /String encoding Shift_JIS is not a supported encoding/)
      end

      it "rejects strings that are using a valid encoding, but do not match the encoding" do
        str = 'A̍̍̀ͬͮr͓͙̣͕͙̭͌̎͐ͅe͔͈̰̊̌ͭͪ ̺̱̭̣̺̗͉w̫ͯ̽̇͊̋̓e̝͚̥̭ͅ ̈́̀h̲͍̤ͮͦ̃͆a͙̼̯̦͂ͤ̏́v͉̩̑͆͛ͮͬ͐i̥͈͖͍̠͈ͥͮ̍̊̎ṅ͈̞̲̘̮̳̎ͩͦg͕̿̔ ̻̺ͥ̉ͨ̆ͬ̐̚f̐͆u̱͔̯̪̟̪̗ͨ́ṅͨ̑ ͈̺̣͖̺̿́ͭ̇ẏ̊̿͒ͫë͉̲̩̯̗̱́͆ͯͩͪ̚t̼̥̤͕̥̭̞̿̇͒?̱̤ͪ͐͒̀'.force_encoding(Encoding::ASCII)
        expect {
          subject.validate(str)
        }.to raise_error(Facter::Util::Validation::ValidationError, /String.*doesn't match.*ASCII/)
      end
    end

    describe "and string encoding is not supported", :unless => String.instance_methods.include?(:encoding) do
      it "doesn't check encoding information" do
        str = 'A̍̍̀ͬͮr͓͙̣͕͙̭͌̎͐ͅe͔͈̰̊̌ͭͪ ̺̱̭̣̺̗͉w̫ͯ̽̇͊̋̓e̝͚̥̭ͅ ̈́̀h̲͍̤ͮͦ̃͆a͙̼̯̦͂ͤ̏́v͉̩̑͆͛ͮͬ͐i̥͈͖͍̠͈ͥͮ̍̊̎ṅ͈̞̲̘̮̳̎ͩͦg͕̿̔ ̻̺ͥ̉ͨ̆ͬ̐̚f̐͆u̱͔̯̪̟̪̗ͨ́ṅͨ̑ ͈̺̣͖̺̿́ͭ̇ẏ̊̿͒ͫë͉̲̩̯̗̱́͆ͯͩͪ̚t̼̥̤͕̥̭̞̿̇͒?̱̤ͪ͐͒̀'.force_encoding(Encoding::SHIFT_JIS)
        expect { subject.validate(str) }.to_not raise_error
      end
    end
  end

  describe "validating arrays" do
    it "validates each element in the array" do
      arr = ['first', 'second', ['third', 'fourth']]

      subject.expects(:validate).with('first')
      subject.expects(:validate).with('second')
      subject.expects(:validate).with(['third', 'fourth'])

      subject.validate_array(arr)
    end
  end

  describe "validating hashes" do
    it "validates each element in the array" do
      hsh = {'first' => 'second', 'third' => ['fourth', 'fifth']}

      subject.expects(:validate).with('first')
      subject.expects(:validate).with('second')
      subject.expects(:validate).with('third')
      subject.expects(:validate).with(['fourth', 'fifth'])

      subject.validate_hash(hsh)
    end
  end

  [1, 1.0, true, false, nil].each do |val|
    it "accepts #{val.inspect}:#{val.class}" do
      expect { subject.validate(val) }.to_not raise_error
    end
  end

  [:sym, Object.new, Set.new].each do |val|
    it "rejects #{val.inspect}:#{val.class}" do
      expect {
        subject.validate(val)
      }.to raise_error(Facter::Util::Validation::ValidationError, /Expected .*but was #{val.class}/ )
    end
  end
end

