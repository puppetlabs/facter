#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/confine'
require 'facter/util/values'

include Facter::Util::Values

describe Facter::Util::Confine do
  it "should require a fact name" do
    Facter::Util::Confine.new("yay", true).fact.should == "yay"
  end

  it "should accept a value specified individually" do
    Facter::Util::Confine.new("yay", "test").values.should == ["test"]
  end

  it "should accept multiple values specified at once" do
    Facter::Util::Confine.new("yay", "test", "other").values.should == ["test", "other"]
  end

  it "should fail if no fact name is provided" do
    lambda { Facter::Util::Confine.new(nil, :test) }.should raise_error(ArgumentError)
  end

  it "should fail if no values were provided" do
    lambda { Facter::Util::Confine.new("yay") }.should raise_error(ArgumentError)
  end

  it "should have a method for testing whether it matches" do
    Facter::Util::Confine.new("yay", :test).should respond_to(:true?)
  end

  describe "when evaluating" do
    def confined(fact_value, *confines)
      @fact.stubs(:value).returns fact_value
      Facter::Util::Confine.new("yay", *confines).true?
    end

    before do
      @fact = mock 'fact'
      Facter.stubs(:[]).returns @fact
    end

    it "should return false if the fact does not exist" do
      Facter.expects(:[]).with("yay").returns nil

      Facter::Util::Confine.new("yay", "test").true?.should be_false
    end

    it "should use the returned fact to get the value" do
      Facter.expects(:[]).with("yay").returns @fact

      @fact.expects(:value).returns nil

      Facter::Util::Confine.new("yay", "test").true?
    end

    it "should return false if the fact has no value" do
      confined(nil, "test").should be_false
    end

    it "should return true if any of the provided values matches the fact's value" do
      confined("two", "two").should be_true
    end

    it "should return true if any of the provided symbol values matches the fact's value" do
      confined(:xy, :xy).should be_true
    end

    it "should return true if any of the provided integer values matches the fact's value" do
      confined(1, 1).should be_true
    end

    it "should return true if any of the provided boolan values matches the fact's value" do
      confined(true, true).should be_true
    end

    it "should return true if any of the provided array values matches the fact's value" do
      confined([3,4], [3,4]).should be_true
    end

    it "should return true if any of the provided symbol values matches the fact's string value" do
      confined(:one, "one").should be_true
    end

    it "should return true if any of the provided string values matches case-insensitive the fact's value" do
      confined("four", "Four").should be_true
    end

    it "should return true if any of the provided symbol values matches case-insensitive the fact's string value" do
      confined(:four, "Four").should be_true
    end

    it "should return true if any of the provided symbol values matches the fact's string value" do
      confined("xy", :xy).should be_true
    end

    it "should return true if any of the provided regexp values matches the fact's string value" do
      confined("abc", /abc/).should be_true
    end

    it "should return true if any of the provided ranges matches the fact's value" do
      confined(6, (5..7)).should be_true
    end

    it "should return false if none of the provided values matches the fact's value" do
      confined("three", "two", "four").should be_false
    end

    it "should return false if none of the provided integer values matches the fact's value" do
      confined(2, 1, [3,4], (5..7)).should be_false
    end

    it "should return false if none of the provided boolan values matches the fact's value" do
      confined(false, true).should be_false
    end

    it "should return false if none of the provided array values matches the fact's value" do
      confined([1,2], [3,4]).should be_false
    end

    it "should return false if none of the provided ranges matches the fact's value" do
      confined(8, (5..7)).should be_false
    end

    it "should accept and evaluate a block argument against the fact" do
      @fact.expects(:value).returns 'foo'
      confine = Facter::Util::Confine.new :yay do |f| f === 'foo' end
      confine.true?.should be_true
    end

    it "should return false if the block raises a StandardError when checking a fact" do
      @fact.stubs(:value).returns 'foo'
      confine = Facter::Util::Confine.new :yay do |f| raise StandardError end
      confine.true?.should be_false
    end

    it "should accept and evaluate only a block argument" do
      Facter::Util::Confine.new { true }.true?.should be_true
      Facter::Util::Confine.new { false }.true?.should be_false
    end

    it "should return false if the block raises a StandardError" do
      Facter::Util::Confine.new { raise StandardError }.true?.should be_false
    end
  end
end
