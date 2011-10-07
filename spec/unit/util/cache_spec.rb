#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'

describe Facter::Util::Cache do
  include FacterSpec::Files

  describe "when storing data" do
    before :each do
      Facter::Util::Config.cache_file = tmpfile
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
      lambda { Facter::Util::Cache.get("foo",0) }.should raise_exception
    end

    it "should cache forever when TTL is set to -1" do
      Facter::Util::Cache.set("foo", "bar", -1)

      now = Time.now
      Time.stubs(:now).returns(now + 1_000_000)
      Facter::Util::Cache.get("foo",-1).should == "bar"
    end

    it "should not cache data whose TTL is set to -100" do
      Facter::Util::Cache.set("foo", "bar", -100)
      lambda { Facter::Util::Cache.get("foo",-100) }.should raise_exception
    end

    it "should discard data that has expired according to the TTL" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.get("foo",1).should == "bar"

      now = Time.now
      Time.stubs(:now).returns(now + 30)
      lambda { Facter::Util::Cache.get("foo",1) }.should raise_exception
    end
  end

  describe "when reading and writing to disk" do
    let(:cache_file) { tmpfile }

    before :each do
      Facter::Util::Config.cache_file = cache_file
    end

    it "should be able to save the data to disk" do
      Facter::Util::Cache.write!
      File.should be_exist(cache_file)
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
      lambda { Facter::Util::Cache.get("foo",1) }.should raise_exception
    end
  end

  describe "when cache file is not writeable" do
    let(:cache_file) { tmpfile }

    before :each do
      File.open(cache_file, "w") do |f|
        f.write("")
      end
      File.chmod(0000, cache_file)
      Facter::Util::Config.cache_file = cache_file
    end

    after :each do
      # Reset permissions so files can be cleaned up
      File.chmod(0644, cache_file)
    end

    it "setting and getting cache should still work" do
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.write!
      Facter::Util::Cache.get("foo",1).should == "bar"
    end
  end

  describe "when cache file has invalid data" do
    before :each do
      cache_file = tmpfile
      File.open(cache_file, "w") do |f|
        f.write("foobar data")
      end
      Facter::Util::Config.cache_file = cache_file
    end

    it "should return empty data set" do
      Facter::Util::Cache.load
      Facter::Util::Cache.all.should == {}
    end

    it "should allow overwriting" do
      Facter::Util::Cache.load
      Facter::Util::Cache.all.should == {}
      Facter::Util::Cache.set("foo", "bar", 1)
      Facter::Util::Cache.load
      Facter::Util::Cache.get("foo", 1).should == "bar"
    end
  end

end
