#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'
require 'tempfile'

describe Facter::Util::Cache do
  def mk_test_dir
    file = Tempfile.new "testing_fact_caching_dir"
    @dir = file.path
    file.delete

    Dir.mkdir(@dir)
    @dirs << @dir # for cleanup

    @dir
  end

  def mk_test_file
    file = Tempfile.new "testing_fact_caching_file"
    @filename = file.path
    file.delete
    @files << @filename # for cleanup

    @filename
  end

  before {
    @files = []
    @dirs = []
    @cache = Facter::Util::Cache.new(mk_test_file)
    @filename = @cache.filename
  }

  after do
    @files.each do |file|
      File.unlink(file) if File.exist?(file)
    end
    @dirs.each do |dir|
      FileUtils.rm_f(dir) if File.exist?(dir)
    end
  end

  it "should make the required filename available" do
    @cache.filename.should be_instance_of(String)
  end

  describe "when determining TTL" do
    it "should determine a file's TTL by looking in a file named after the file with a '.ttl' extension" do
      dir = mk_test_dir
      file = File.join(dir, "myscript")
      File.open(file + ".ttl", "w") { |f| f.print 300 }

      @cache.ttl(file).should == 300
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
      other_cache.load
      other_cache["foo"].should == "bar"
    end

    it "should load data the first time data is asked for" do
      @cache["foo"] = "bar"

      other_cache = @cache.class.new(@cache.filename)
      other_cache["foo"].should == "bar"
    end

    it "should be able to return both old and new data when loading from disk" do
      @cache["foo"] = "bar"

      other_cache = @cache.class.new(@cache.filename)
      other_cache["biz"] = "baz"

      third_cache = @cache.class.new(@cache.filename)
      third_cache["foo"].should == "bar"
      third_cache["biz"].should == "baz"
    end

    it "should forever cache data whose TTL is set to less than 1" do
      @cache.stubs(:ttl).returns 0
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should == "foo"
      @cache["/my/file"].should == "foo"
    end

    it "should discard data that has expired according to the TTL" do
      now = Time.now
      @cache["/my/file"] = "foo"
      @cache["/my/file"].should == "foo"

      Time.expects(:now).returns(now + 30)
      @cache.expects(:ttl).returns 1
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
      other_cache.expects(:ttl).returns 1
      other_cache["/my/file"].should be_nil
    end
  end
end
