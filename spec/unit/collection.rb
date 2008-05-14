#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../spec_helper'

require 'facter/collection'

describe Facter::Collection do
    it "should have a method for adding facts" do
        Facter::Collection.new.should respond_to(:add)
    end

    describe "when adding facts" do
        before do
            @coll = Facter::Collection.new
        end

        it "should create a new fact if no fact with the same name already exists" do
            fact = mock 'fact'
            Facter::Fact.expects(:new).with { |name, *args| name == :myname }.returns fact

            @coll.add(:myname)
        end

        describe "and a block is provided" do
            it "should use the block to add a resolution to the fact" do
                fact = mock 'fact'
                Facter::Fact.expects(:new).returns fact

                fact.expects(:add)

                @coll.add(:myname) {}
            end
        end
    end

    it "should have a method for retrieving facts by name" do
        Facter::Collection.new.should respond_to(:fact)
    end

    describe "when retrieving facts" do
        before do
            @coll = Facter::Collection.new

            @fact = @coll.add("YayNess")
        end

        it "should return the fact instance specified by the name" do
            @coll.fact("YayNess").should equal(@fact)
        end

        it "should be case-insensitive" do
            @coll.fact("yayness").should equal(@fact)
        end
        
        it "should treat strings and symbols equivalently" do
            @coll.fact(:yayness).should equal(@fact)
        end
    end

    it "should have a method for returning a fact's value" do
        Facter::Collection.new.should respond_to(:value)
    end

    describe "when returning a fact's value" do
        before do
            @coll = Facter::Collection.new
            @fact = @coll.add("YayNess")

            @fact.stubs(:value).returns "result"
        end

        it "should return the result of calling :value on the fact" do
            @fact.expects(:value).returns "result"

            @coll.value("YayNess").should == "result"
        end

        it "should be case-insensitive" do
            @coll.value("yayness").should_not be_nil
        end
        
        it "should treat strings and symbols equivalently" do
            @coll.value(:yayness).should_not be_nil
        end
    end

    it "should return the fact's value when the array index method is used" do
        @coll = Facter::Collection.new
        @coll.expects(:value).with("myfact").returns "foo"
        @coll["myfact"].should == "foo"
    end

    it "should have a method for flushing all facts" do
        @coll = Facter::Collection.new
        @fact = @coll.add("YayNess")

        @fact.expects(:flush)

        @coll.flush
    end

    it "should have a method that returns all fact names" do
        @coll = Facter::Collection.new
        @coll.add(:one)
        @coll.add(:two)

        @coll.list.sort.should == [:one, :two].sort
    end

    it "should have a method for returning a hash of fact values" do
        Facter::Collection.new.should respond_to(:to_hash)
    end

    describe "when returning a hash of values" do
        before do
            @coll = Facter::Collection.new
            @fact = @coll.add(:one)
            @fact.stubs(:value).returns "me"
        end

        it "should return a hash of fact names and values with the fact names as strings" do
            @coll.to_hash.should == {"one" => "me"}
        end

        it "should not include facts that did not return a value" do
            f = @coll.add(:two)
            f.stubs(:value).returns nil
            @coll.to_hash.should_not be_include(:two)
        end
    end

    it "should have a method for iterating over all facts" do
        Facter::Collection.new.should respond_to(:each)
    end

    it "should include Enumerable" do
        Facter::Collection.ancestors.should be_include(Enumerable)
    end

    describe "when iterating over facts" do
        before do
            @coll = Facter::Collection.new
            @one = @coll.add(:one)
            @two = @coll.add(:two)
        end

        it "should yield each fact name and the fact value" do
            @one.stubs(:value).returns "ONE"
            @two.stubs(:value).returns "TWO"
            facts = {}
            @coll.each do |fact, value|
                facts[fact] = value
            end
            facts.should == {"one" => "ONE", "two" => "TWO"}
        end

        it "should convert the fact name to a string" do
            @one.stubs(:value).returns "ONE"
            @two.stubs(:value).returns "TWO"
            facts = {}
            @coll.each do |fact, value|
                fact.should be_instance_of(String)
            end
        end

        it "should only yield facts that have values" do
            @one.stubs(:value).returns "ONE"
            @two.stubs(:value).returns nil
            facts = {}
            @coll.each do |fact, value|
                facts[fact] = value
            end

            facts.should_not be_include("two")
        end
    end
end
