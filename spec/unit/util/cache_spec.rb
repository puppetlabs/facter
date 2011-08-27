#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'
require 'tempfile'

describe Facter::Util::Cache do
  include FacterSpec::Files

  it "should make the required filename available" do
    filename = tmpfile
    cache = Facter::Util::Cache.new(filename)
    cache.filename.should == filename
  end

  describe "when determining TTL" do
    before :each do
      @cache = Facter::Util::Cache.new(tmpfile)
      dir = tmpdir
      @script_file = File.join(dir, "myscript")
      @ttl_file = @script_file + ".ttl"
    end
    
    it "should determine TTL by looking in a file named after the external fact file with a '.ttl' extension" do
      File.open(@ttl_file, "w") { |f| f.print 300 }

      @cache.ttl(@script_file).should == 300
    end

    it "should support a -1 for TTL" do
      File.open(@ttl_file, "w") { |f| f.print -1 }

      @cache.ttl(@script_file).should == -1
    end

    it "should return 0 when ttl file doesn't contain a number" do
      File.open(@ttl_file, "w") { |f| f.print "some weird data" }

      @cache.ttl(@script_file).should == 0
    end

    it "should return 0 when no ttl file is provided" do
      @cache.ttl(@script_file).should == 0
    end
  end

  describe "when storing data" do
    before :each do
      @cache = Facter::Util::Cache.new(tmpfile)
      @cache.stubs(:ttl).returns(1)
    end

    it "should store the provided data in the cache" do
      @cache["/my/file"] = {:foo => :bar}
      @cache["/my/file"].should == {:foo => :bar}
    end

    it "should save the data to disk immediately" do
      @cache["foo"] = "bar"

      other_cache = @cache.class.new(@cache.filename)
      other_cache.stubs(:ttl).returns(1)
      other_cache.load
      other_cache["foo"].should == "bar"
    end

    it "should load data the first time data is asked for" do
      @cache["foo"] = "bar"

      other_cache = @cache.class.new(@cache.filename)
      other_cache.stubs(:ttl).returns(1)
      other_cache["foo"].should == "bar"
    end

    it "should be able to return both old and new data when loading from disk" do
      @cache["foo"] = "bar"
      @cache["foo"].should == "bar"

      other_cache = @cache.class.new(@cache.filename)
      other_cache.stubs(:ttl).returns(1)
      other_cache["biz"] = "baz"
      other_cache["biz"].should == "baz"

      third_cache = @cache.class.new(@cache.filename)
      third_cache.stubs(:ttl).returns(1)
      third_cache["foo"].should == "bar"
      third_cache["biz"].should == "baz"
    end

    it "should not cache data whose TTL is set to 0" do
      @cache.stubs(:ttl).returns(0)
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should be_nil
    end

    it "should cache forever when TTL is set to -1" do
      @cache.stubs(:ttl).returns(-1)
      @cache["/my/file"] = "foo"

      now = Time.now
      Time.stubs(:now).returns(now + 1_000_000_000)
      @cache["/my/file"].should == "foo"
    end

    it "should not cache data whose TTL is set to -100" do
      @cache.stubs(:ttl).returns(-100)
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should be_nil
    end

    it "should discard data that has expired according to the TTL" do
      now = Time.now
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should == "foo"

      Time.stubs(:now).returns(now + 30)
      @cache["/my/file"].should be_nil
    end
  end

  describe "when reading and writing to disk" do
    before :each do
      @cache = Facter::Util::Cache.new(tmpfile)
      @cache.stubs(:ttl).returns(1)
    end

    it "should be able to save the data to disk" do
      @cache.write!
      File.should be_exist(@cache.filename)
    end

    it "should be able to return data saved to disk" do
      @cache["foo"] = "bar"
      @cache.write!

      other_cache = @cache.class.new(@cache.filename)
      other_cache.stubs(:ttl).returns(1)
      other_cache.load
      other_cache["foo"].should == "bar"
    end

    it "should retain the data age when storing on disk" do
      now = Time.now
      @cache["/my/file"] = "foo"

      @cache.write!

      other_cache = @cache.class.new(@cache.filename)
      other_cache.load

      Time.stubs(:now).returns(now + 30)
      other_cache.stubs(:ttl).returns 1
      other_cache["/my/file"].should be_nil
    end
  end
end
