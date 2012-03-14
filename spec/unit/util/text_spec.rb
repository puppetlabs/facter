#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/text'

describe Facter::Util::Text do
  let(:text) { Facter::Util::Text.new }
  let(:stdout) { StringIO.new }

  before :each do
    $stdout = stdout
  end

  after :each do
    $stdout = STDOUT
  end

  context "pretty_output" do
    before :each do
      # Disable color for these tests
      Facter::Util::Text.any_instance.stubs(:color?).returns(false)
    end

    it "should output strings with quotes" do
      text.pretty_output("test string")
      stdout.string.should == "\"test string\"\n"
    end

    it "should output boolean true without quotes" do
      text.pretty_output(true)
      stdout.string.should == "true\n"
    end

    it "should output boolean false without quotes" do
      text.pretty_output(false)
      stdout.string.should == "false\n"
    end

    pending "should output nil without quotes" do
      # Not sure if this should return 'undef' or not yet
      text.pretty_output(nil)
      stdout.string.should == "nil\n"
    end

    it "should output integers without quotes" do
      text.pretty_output(3)
      stdout.string.should == "3\n"
    end

    it "should output floats without quotes" do
      text.pretty_output(3.45)
      stdout.string.should == "3.45\n"
    end

    it "should output negative floats without quotes" do
      text.pretty_output(-3.45)
      stdout.string.should == "-3.45\n"
    end

    it "should handle outputting arrays of strings" do
      text.pretty_output(["a","b","c"])
      stdout.string.should == <<-EOS
[
  "a",
  "b",
  "c",
]
      EOS
    end

    it "should handle outputting arrays of mixed types" do
      text.pretty_output([1,"a",true])
      stdout.string.should == <<-EOS
[
  1,
  "a",
  true,
]
      EOS
    end

    it "should handle outputting hashes with string keys and numeric values" do
      text.pretty_output({"a"=>1,"b"=>2,"c"=>3})
      stdout.string.should == <<-EOS
{
  "a" => 1,
  "b" => 2,
  "c" => 3,
}
      EOS
    end

    it "should handle outputting arrays of hashes with string keys and numeric values" do
      text.pretty_output([{"a"=>1,"b"=>2},{"c"=>3,"d"=>4}])
      stdout.string.should == <<-EOS
[
  {
    "a" => 1,
    "b" => 2,
  },
  {
    "c" => 3,
    "d" => 4,
  },
]
      EOS
    end

    it "should handle outputting hashes with arrays with mixed types for values" do
      text.pretty_output({"a"=>[1,true,"a"],"b"=>true,"c"=>[true,"a",1]})
      stdout.string.should == <<-EOS
{
  "a" => [
    1,
    true,
    "a",
  ],
  "b" => true,
  "c" => [
    true,
    "a",
    1,
  ],
}
      EOS
    end

    it "should handle hashes of hashes" do
      text.pretty_output({"a"=>{"a"=>1,"b"=>2},"b"=>{"a"=>1,"b"=>2}})
      stdout.string.should == <<-EOS
{
  "a" => {
    "a" => 1,
    "b" => 2,
  },
  "b" => {
    "a" => 1,
    "b" => 2,
  },
}
      EOS
    end
  end

  context "facter_output" do
    before :each do
      # Disable color for these tests
      Facter::Util::Text.any_instance.stubs(:color?).returns(false)
    end

    it "should handle string types on the left hand side" do
      text.facter_output({"fact" => "a"})
      stdout.string.should == "$fact = \"a\"\n"
    end

    it "should handle numbers on the left hand side" do
      text.facter_output({"fact" => 3})
      stdout.string.should == "$fact = 3\n"
    end

    it "should handle booleans on the left hand side" do
      text.facter_output({"fact" => true})
      stdout.string.should == "$fact = true\n"
    end

    it "should handle arrays on the left hand side" do
      text.facter_output({"fact" => ["a","b"]})
      stdout.string.should == <<-EOS
$fact = [
  "a",
  "b",
]
      EOS
    end

    it "should handle hashes on the left hand side" do
      text.facter_output({"fact" => {"a"=>1,"b"=>2}})
      stdout.string.should == <<-EOS
$fact = {
  "a" => 1,
  "b" => 2,
}
      EOS
    end

    it "should adjust first equals based on longest fact name" do
      text.facter_output({
        "fact1" => "value",
        "longfactname" => "value",
      })
      stdout.string.should == <<-EOS
$fact1        = "value"
$longfactname = "value"
      EOS
    end
  end
end
