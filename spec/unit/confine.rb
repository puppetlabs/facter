#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../spec_helper'

require 'facter/confine'

describe Facter::Confine do
    it "should require a fact name" do
        Facter::Confine.new("yay", true).fact.should == "yay"
    end

    it "should accept a value specified individually" do
        Facter::Confine.new("yay", "test").values.should == ["test"]
    end

    it "should accept multiple values specified at once" do
        Facter::Confine.new("yay", "test", "other").values.should == ["test", "other"]
    end

    it "should convert all values to strings" do
        Facter::Confine.new("yay", :test).values.should == %w{test}
    end

    it "should fail if no fact name is provided" do
        lambda { Facter::Confine.new(nil, :test) }.should raise_error(ArgumentError)
    end

    it "should fail if no values were provided" do
        lambda { Facter::Confine.new("yay") }.should raise_error(ArgumentError)
    end

    it "should have a method for testing whether it matches" do
        Facter::Confine.new("yay", :test).should respond_to(:true?)
    end

    describe "when evaluating" do
        before do
            @confine = Facter::Confine.new("yay", "one", "two")
            @fact = mock 'fact'
            Facter.stubs(:[]).returns @fact
        end

        it "should return false if the fact does not exist" do
            Facter.expects(:[]).with("yay").returns nil

            @confine.true?.should be_false
        end

        it "should use the returned fact to get the value" do
            Facter.expects(:[]).with("yay").returns @fact

            @fact.expects(:value).returns nil

            @confine.true?
        end

        it "should return false if the fact has no value" do
            @fact.stubs(:value).returns nil

            @confine.true?.should be_false
        end

        it "should return true if any of the provided values matches the fact's value" do
            @fact.stubs(:value).returns "two"

            @confine.true?.should be_true
        end

        it "should return false if none of the provided values matches the fact's value" do
            @fact.stubs(:value).returns "three"

            @confine.true?.should be_false
        end
    end
end
