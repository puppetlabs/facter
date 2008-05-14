#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../spec_helper'

require 'facter/resolution'

describe Facter::Resolution do
    it "should require a name" do
        lambda { Facter::Resolution.new }.should raise_error(ArgumentError)
    end

    it "should have a name" do
        Facter::Resolution.new("yay").name.should == "yay"
    end

    it "should have a method for setting the code" do
        Facter::Resolution.new("yay").should respond_to(:setcode)
    end

    describe "when setting the code" do
        before do
            @resolve = Facter::Resolution.new("yay")
        end

        it "should default to /bin/sh as the interpreter if a string is provided" do
            @resolve.setcode "foo"
            @resolve.interpreter.should == "/bin/sh"
        end

        it "should set the code to any provided string" do
            @resolve.setcode "foo"
            @resolve.code.should == "foo"
        end

        it "should set the code to any provided block" do
            block = lambda { }
            @resolve.setcode(&block)
            @resolve.code.should equal(block)
        end

        it "should prefer the string over a block" do
            @resolve.setcode("foo") { }
            @resolve.code.should == "foo"
        end

        it "should fail if neither a string nor block has been provided" do
            lambda { @resolve.setcode }.should raise_error(ArgumentError)
        end
    end

    it "should be able to return a value" do
        Facter::Resolution.new("yay").should respond_to(:value)
    end

    describe "when returning the value" do
        before do
            @resolve = Facter::Resolution.new("yay")
        end

        describe "and the code is a string" do
            it "should return the result of executing the code with the interpreter" do
                @resolve.setcode "/bin/foo"
                Facter::Resolution.expects(:exec).with("/bin/foo", "/bin/sh").returns "yup"

                @resolve.value.should == "yup"
            end

            it "should return nil if the value is an empty string" do
                @resolve.setcode "/bin/foo"
                Facter::Resolution.stubs(:exec).returns ""
                @resolve.value.should be_nil
            end
        end

        describe "and the code is a block" do
            it "should return the value returned by the block" do
                @resolve.setcode { "yayness" }
                @resolve.value.should == "yayness"
            end

            it "should return nil if the value is an empty string" do
                @resolve.setcode { "" }
                @resolve.value.should be_nil
            end
        end
    end

    it "should return its value when converted to a string" do
        @resolve = Facter::Resolution.new("yay")
        @resolve.expects(:value).returns "myval"
        @resolve.to_s.should == "myval"
    end

    it "should allow the adding of confines" do
        Facter::Resolution.new("yay").should respond_to(:confine)
    end

    it "should provide a method for returning the number of confines" do
        @resolve = Facter::Resolution.new("yay")
        @resolve.confine "one" => "foo", "two" => "fee"
        @resolve.length.should == 2
    end

    it "should return 0 confines when no confines have been added" do
        Facter::Resolution.new("yay").length.should == 0
    end

    it "should have a method for determining if it is suitable" do
        Facter::Resolution.new("yay").should respond_to(:suitable?)
    end

    describe "when adding confines" do
        before do
            @resolve = Facter::Resolution.new("yay")
        end

        it "should accept a hash of fact names and values" do
            lambda { @resolve.confine :one => "two" }.should_not raise_error
        end

        it "should create a Confine instance for every argument in the provided hash" do
            Facter::Confine.expects(:new).with("one", "foo")
            Facter::Confine.expects(:new).with("two", "fee")

            @resolve.confine "one" => "foo", "two" => "fee"
        end

    end

    describe "when determining suitability" do
        before do
            @resolve = Facter::Resolution.new("yay")
        end

        it "should always be suitable if no confines have been added" do
            @resolve.should be_suitable
        end

        it "should be unsuitable if any provided confines return false" do
            confine1 = mock 'confine1', :true? => true
            confine2 = mock 'confine2', :true? => false
            Facter::Confine.expects(:new).times(2).returns(confine1).then.returns(confine2)
            @resolve.confine :one => :two, :three => :four

            @resolve.should_not be_suitable
        end

        it "should be suitable if all provided confines return true" do
            confine1 = mock 'confine1', :true? => true
            confine2 = mock 'confine2', :true? => true
            Facter::Confine.expects(:new).times(2).returns(confine1).then.returns(confine2)
            @resolve.confine :one => :two, :three => :four

            @resolve.should be_suitable
        end
    end

    it "should have a class method for executing code" do
        Facter::Resolution.should respond_to(:exec)
    end

    # It's not possible, AFAICT, to mock %x{}, so I can't really test this bit.
    describe "when executing code" do
        it "should fail if any interpreter other than /bin/sh is requested" do
            lambda { Facter::Resolution.exec("/something", "/bin/perl") }.should raise_error(ArgumentError)
        end
    end
end
