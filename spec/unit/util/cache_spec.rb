#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'
require 'tempfile'

describe Facter::Util::Cache do
  include FacterSpec::Files

  it "should make the required filename available" do
    filename = tmpfile
    Facter::Util::Cache.filename = filename
    Facter::Util::Cache.filename.should == filename
  end

  describe "when storing data" do
    before :each do
      Facter::Util::Cache.filename = tmpfile
    end

    it "should store the provided data in the cache" do
      Facter::Util::Cache.set("/my/file", {:foo => :bar}, 1)
      Facter::Util::Cache.get("/my/file",1).should == {:foo => :bar}
    end

    it "should save the data to disk immediately" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.load
      Facter::Util::Cache.get("foo",1).should == "bar"
    end

    it "should load data the first time data is asked for" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.get("foo",1).should == "bar"
    end

    it "should be able to return both old and new data when loading from disk" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.get("foo",1).should == "bar"

      Facter::Util::Cache.set("biz", "baz", 1)
      Facter::Util::Cache.get("biz",1).should == "baz"

      Facter::Util::Cache.get("foo",1).should == "bar"
      Facter::Util::Cache.get("biz",1).should == "baz"
    end

    it "should not cache data whose TTL is set to 0" do
      Facter::Util::Cache.set("foo", "bar", 0)
      Facter::Util::Cache.get("foo",0).should be_nil
    end

    it "should cache forever when TTL is set to -1" do
      Facter::Util::Cache.set("foo", "bar", -1)

      now = Time.now
      Time.stubs(:now).returns(now + 1_000_000)
      Facter::Util::Cache.get("foo",-1).should == "bar"
    end

    it "should not cache data whose TTL is set to -100" do
      Facter::Util::Cache.set("foo", "bar", -100)
      Facter::Util::Cache.get("foo",-100).should be_nil
    end

    it "should discard data that has expired according to the TTL" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.get("foo",1).should == "bar"

      now = Time.now
      Time.stubs(:now).returns(now + 30)
      Facter::Util::Cache.get("foo",1).should be_nil
    end
  end

  describe "when reading and writing to disk" do
    before :each do
      @@cache_file = tmpfile
      Facter::Util::Cache.filename = @@cache_file
    end

    it "should be able to save the data to disk" do
      Facter::Util::Cache.write!
      File.should be_exist(@@cache_file)
    end

    it "should be able to return data saved to disk" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.write!
 
      Facter::Util::Cache.load
      Facter::Util::Cache.get("foo",1).should == "bar"
    end

    it "should retain the data age when storing on disk" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.write!

      Facter::Util::Cache.load

      now = Time.now
      Time.stubs(:now).returns(now + 30)
      Facter::Util::Cache.get("foo",1).should be_nil
    end
  end
end
