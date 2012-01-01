#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/collection'

describe Facter::Util::Collection do
  it "should have a method for adding facts" do
    Facter::Util::Collection.new.should respond_to(:add)
  end

  it "should have a method for returning a loader" do
    Facter::Util::Collection.new.should respond_to(:loader)
  end

  it "should use an instance of the Loader class as its loader" do
    Facter::Util::Collection.new.loader.should be_instance_of(Facter::Util::Loader)
  end

  it "should cache its loader" do
    coll = Facter::Util::Collection.new
    coll.loader.should equal(coll.loader)
  end

  it "should have a method for loading all facts" do
    Facter::Util::Collection.new.should respond_to(:load_all)
  end

  it "should delegate its load_all method to its loader" do
    coll = Facter::Util::Collection.new
    coll.loader.expects(:load_all)
    coll.load_all
  end

  describe "when adding facts" do
    before do
      @coll = Facter::Util::Collection.new
    end

    it "should create a new fact if no fact with the same name already exists" do
      @coll.add(:myname)
      @coll.fact(:myname).name.should == :myname
    end

    it "should accept options" do
      @coll.add(:myname, :ldapname => "whatever") { }
    end

    it "should set any appropriate options on the fact instances" do
      # Use a real fact instance, because we're using respond_to?
      fact = Facter::Util::Fact.new(:myname)

      @coll.add(:myname, :ldapname => "testing")
      @coll.fact(:myname).ldapname.should == "testing"
    end

    it "should set appropriate options on the resolution instance" do
      fact = Facter::Util::Fact.new(:myname)
      Facter::Util::Fact.expects(:new).with(:myname).returns fact

      resolve = Facter::Util::Resolution.new(:myname) {}
      fact.expects(:add).returns resolve

      @coll.add(:myname, :timeout => "myval") {}
    end

    it "should not pass fact-specific options to resolutions" do
      fact = Facter::Util::Fact.new(:myname)
      Facter::Util::Fact.expects(:new).with(:myname).returns fact

      resolve = Facter::Util::Resolution.new(:myname) {}
      fact.expects(:add).returns resolve

      fact.expects(:ldapname=).with("foo")
      resolve.expects(:timeout=).with("myval")

      @coll.add(:myname, :timeout => "myval", :ldapname => "foo") {}
    end

    it "should fail if invalid options are provided" do
      lambda { @coll.add(:myname, :foo => :bar) }.should raise_error(ArgumentError)
    end

    describe "and a block is provided" do
      it "should use the block to add a resolution to the fact" do
        fact = mock 'fact'
        Facter::Util::Fact.expects(:new).returns fact

        fact.expects(:add)

        @coll.add(:myname) {}
      end

      it "should discard resolutions that throw an exception when added" do
        lambda {
          @coll.add('yay') do
            raise
            setcode { 'yay' }
          end
        }.should_not raise_error
        @coll.value('yay').should be_nil
      end
    end
  end

  it "should have a method for retrieving facts by name" do
    Facter::Util::Collection.new.should respond_to(:fact)
  end

  describe "when retrieving facts" do
    before do
      @coll = Facter::Util::Collection.new

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

    it "should use its loader to try to load the fact if no fact can be found" do
      @coll.loader.expects(:load).with(:testing)
      @coll.fact("testing")
    end

    it "should return nil if it cannot find or load the fact" do
      @coll.loader.expects(:load).with(:testing)
      @coll.fact("testing").should be_nil
    end
  end

  it "should have a method for returning a fact's value" do
    Facter::Util::Collection.new.should respond_to(:value)
  end

  describe "when returning a fact's value" do
    before do
      @coll = Facter::Util::Collection.new
      @fact = @coll.add("YayNess")

      @fact.stubs(:value).returns "result"
    end

    it "should use the 'fact' method to retrieve the fact" do
      @coll.expects(:fact).with(:yayness).returns @fact
      @coll.value(:yayness)
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
    @coll = Facter::Util::Collection.new
    @coll.expects(:value).with("myfact").returns "foo"
    @coll["myfact"].should == "foo"
  end

  it "should have a method for flushing all facts" do
    @coll = Facter::Util::Collection.new
    @fact = @coll.add("YayNess")

    @fact.expects(:flush)

    @coll.flush
  end

  it "should have a method that returns all fact names" do
    @coll = Facter::Util::Collection.new
    @coll.add(:one)
    @coll.add(:two)

    @coll.list.sort { |a,b| a.to_s <=> b.to_s }.should == [:one, :two]
  end

  it "should have a method for returning a hash of fact values" do
    Facter::Util::Collection.new.should respond_to(:to_hash)
  end

  describe "when returning a hash of values" do
    before do
      @coll = Facter::Util::Collection.new
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
    Facter::Util::Collection.new.should respond_to(:each)
  end

  it "should include Enumerable" do
    Facter::Util::Collection.ancestors.should be_include(Enumerable)
  end

  describe "when iterating over facts" do
    before do
      @coll = Facter::Util::Collection.new
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
