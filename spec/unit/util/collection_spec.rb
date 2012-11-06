#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/collection'
require 'facter/util/nothing_loader'

describe Facter::Util::Collection do
  let(:external_loader) { Facter::Util::NothingLoader.new }
  let(:internal_loader) do
    load = Facter::Util::Loader.new
    load.stubs(:load).returns nil
    load.stubs(:load_all).returns nil
    load
  end
  let(:collection) { Facter::Util::Collection.new(internal_loader, external_loader) }

  it "should delegate its load_all method to its loader" do
    internal_loader.expects(:load_all)

    collection.load_all
  end

  describe "when adding facts" do
    it "should create a new fact if no fact with the same name already exists" do
      collection.add(:myname)
      collection.fact(:myname).name.should == :myname
    end

    it "should accept options" do
      collection.add(:myname, :ldapname => "whatever") { }
    end

    it "should set any appropriate options on the fact instances" do
      # Use a real fact instance, because we're using respond_to?
      fact = Facter::Util::Fact.new(:myname)

      collection.add(:myname, :ldapname => "testing")
      collection.fact(:myname).ldapname.should == "testing"
    end

    it "should set appropriate options on the resolution instance" do
      fact = Facter::Util::Fact.new(:myname)
      Facter::Util::Fact.expects(:new).with(:myname).returns fact

      resolve = Facter::Util::Resolution.new(:myname) {}
      fact.expects(:add).returns resolve

      collection.add(:myname, :timeout => "myval") {}
    end

    it "should not pass fact-specific options to resolutions" do
      fact = Facter::Util::Fact.new(:myname)
      Facter::Util::Fact.expects(:new).with(:myname).returns fact

      resolve = Facter::Util::Resolution.new(:myname) {}
      fact.expects(:add).returns resolve

      fact.expects(:ldapname=).with("foo")
      resolve.expects(:timeout=).with("myval")

      collection.add(:myname, :timeout => "myval", :ldapname => "foo") {}
    end

    it "should fail if invalid options are provided" do
      lambda { collection.add(:myname, :foo => :bar) }.should raise_error(ArgumentError)
    end

    describe "and a block is provided" do
      it "should use the block to add a resolution to the fact" do
        fact = mock 'fact'
        Facter::Util::Fact.expects(:new).returns fact

        fact.expects(:add)

        collection.add(:myname) {}
      end

      it "should discard resolutions that throw an exception when added" do
        lambda {
          collection.add('yay') do
            raise
            setcode { 'yay' }
          end
        }.should_not raise_error
        collection.value('yay').should be_nil
      end
    end
  end

  describe "when retrieving facts" do
    before do
      @fact = collection.add("YayNess")
    end

    it "should return the fact instance specified by the name" do
      collection.fact("YayNess").should equal(@fact)
    end

    it "should be case-insensitive" do
      collection.fact("yayness").should equal(@fact)
    end

    it "should treat strings and symbols equivalently" do
      collection.fact(:yayness).should equal(@fact)
    end

    it "should use its loader to try to load the fact if no fact can be found" do
      collection.internal_loader.expects(:load).with(:testing)
      collection.fact("testing")
    end

    it "should return nil if it cannot find or load the fact" do
      collection.internal_loader.expects(:load).with(:testing)
      collection.fact("testing").should be_nil
    end
  end

  describe "when returning a fact's value" do
    before do
      @fact = collection.add("YayNess", :value => "result")
    end

    it "should return the result of calling :value on the fact" do
      collection.value("YayNess").should == "result"
    end

    it "should be case-insensitive" do
      collection.value("yayness").should == "result"
    end

    it "should treat strings and symbols equivalently" do
      collection.value(:yayness).should == "result"
    end
  end

  it "should return the fact's value when the array index method is used" do
    collection.add("myfact", :value => "foo")

    collection["myfact"].should == "foo"
  end

  it "should have a method for flushing all facts" do
    fact = collection.add("YayNess")

    fact.expects(:flush)

    collection.flush
  end

  it "should have a method that returns all fact names" do
    collection.add(:one)
    collection.add(:two)

    collection.list.sort { |a,b| a.to_s <=> b.to_s }.should == [:one, :two]
  end

  describe "when returning a hash of values" do
    it "should return a hash of fact names and values with the fact names as strings" do
      collection.add(:one, :value => "me")

      collection.to_hash.should == {"one" => "me"}
    end

    it "should not include facts that did not return a value" do
      collection.add(:two, :value => nil)

      collection.to_hash.should_not be_include(:two)
    end
  end

  describe "when iterating over facts" do
    before do
      collection.add(:one, :value => "ONE")
      collection.add(:two, :value => "TWO")
    end

    it "should yield each fact name and the fact value" do
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end
      facts.should == {"one" => "ONE", "two" => "TWO"}
    end

    it "should convert the fact name to a string" do
      facts = {}
      collection.each do |fact, value|
        fact.should be_instance_of(String)
      end
    end

    it "should only yield facts that have values" do
      collection.add(:nil_fact, :value => nil)
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end

      facts.should_not be_include("nil_fact")
    end
  end

  describe "when no facts are loaded" do
    it "should warn when no facts were loaded" do
      Facter.expects(:warnonce).with("No facts loaded from #{internal_loader.search_path.join(File::PATH_SEPARATOR)}").once

      collection.fact("one")
    end
  end

  describe "external facts" do
    let(:collection) { Facter::Util::Collection.new(internal_loader, SingleFactLoader.new(:test_fact, "fact value")) }

    it "loads when a specific fact is requested" do
      collection.fact(:test_fact).value.should == "fact value"
    end

    it "loads when facts are listed" do
      collection.list.should == [:test_fact]
    end

    it "loads when all facts are iterated over" do
      facts = []
      collection.each { |fact_name, fact_value| facts << [fact_name, fact_value] }

      facts.should == [["test_fact", "fact value"]]
    end
  end

  class SingleFactLoader
    def initialize(name, value)
      @name = name
      @value = value
    end

    def load(collection)
      collection.add(@name, :value => @value)
    end
  end
end
