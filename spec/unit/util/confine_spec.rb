#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
        before do
            @confine = Facter::Util::Confine.new("yay", "one", "two", "Four", :xy, true, 1, [3,4])
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

        it "should return true if any of the provided symbol values matches the fact's value" do
            @fact.stubs(:value).returns :xy

            @confine.true?.should be_true
        end

        it "should return true if any of the provided integer values matches the fact's value" do
            @fact.stubs(:value).returns 1

            @confine.true?.should be_true
        end

        it "should return true if any of the provided boolan values matches the fact's value" do
            @fact.stubs(:value).returns true

            @confine.true?.should be_true
        end

        it "should return true if any of the provided array values matches the fact's value" do
            @fact.stubs(:value).returns [3,4]

            @confine.true?.should be_true
        end

        it "should return true if any of the provided symbol values matches the fact's string value" do
            @fact.stubs(:value).returns :one

            @confine.true?.should be_true
        end

        it "should return true if any of the provided string values matches case-insensitive the fact's value" do
            @fact.stubs(:value).returns "four"

            @confine.true?.should be_true
        end

        it "should return true if any of the provided symbol values matches case-insensitive the fact's string value" do
            @fact.stubs(:value).returns :four

            @confine.true?.should be_true
        end

        it "should return true if any of the provided symbol values matches the fact's string value" do
            @fact.stubs(:value).returns :Xy

            @confine.true?.should be_true
        end

        it "should return false if none of the provided values matches the fact's value" do
            @fact.stubs(:value).returns "three"

            @confine.true?.should be_false
        end

        it "should return false if none of the provided integer values matches the fact's value" do
            @fact.stubs(:value).returns 2

            @confine.true?.should be_false
        end

        it "should return false if none of the provided boolan values matches the fact's value" do
            @fact.stubs(:value).returns false

            @confine.true?.should be_false
        end

        it "should return false if none of the provided array values matches the fact's value" do
            @fact.stubs(:value).returns [1,2]

            @confine.true?.should be_false
        end
    end
end
