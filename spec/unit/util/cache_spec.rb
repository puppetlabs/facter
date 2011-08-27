#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'
require 'tempfile'

describe Facter::Util::Cache do
  include FacterSpec::Files

  before :each do
    @cache = Facter::Util::Cache.new(tmpfile)
    @cache.stubs(:ttl).returns(1)
  end

  it "should make the required filename available" do
    @cache.filename.should be_instance_of(String)
  end

  describe "when determining TTL" do
    it "should determine TTL by looking in a file named after the external fact file with a '.ttl' extension" do
      @cache.unstub(:ttl)
      dir = tmpdir
      file = File.join(dir, "myscript")
      File.open(file + ".ttl", "w") { |f| f.print 300 }

      @cache.ttl(file).should == 300
    end

    it "should return a ttl of 0 when no ttl file is provided" do
      @cache.unstub(:ttl)
      @cache.ttl(@cache.filename).should == 0
    end
  end

  describe "when storing data" do
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

    it "should discard data that has expired according to the TTL" do
      now = Time.now
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should == "foo"

      Time.expects(:now).returns(now + 30)
      @cache["/my/file"].should be_nil
    end
  end

  describe "when reading and writing to disk" do
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

      Time.expects(:now).returns(now + 30)
      other_cache.stubs(:ttl).returns 1
      other_cache["/my/file"].should be_nil
    end
  end
end
