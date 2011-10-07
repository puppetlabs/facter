#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'facter/util/directory_loader'

describe Facter::Util::DirectoryLoader do
  include FacterSpec::Files

  before :each do
    @loader = Facter::Util::DirectoryLoader.new(tmpdir)
  end

  it "should make the directory available" do
    @loader.directory.should be_instance_of(String)
  end

  it "should default to '/usr/lib/facter/ext' for the directory if not windows" do
    Facter::Util::Config.stubs(:is_windows?).returns(false)
    Facter::Util::DirectoryLoader.new.directory.should == "/usr/lib/facter/ext"
  end

  it "should do nothing bad when dir doesn't exist" do
    fakepath = "/foobar/path"
    my_loader = Facter::Util::DirectoryLoader.new(fakepath)
    FileTest.exists?(my_loader.directory).should be_false
    my_loader.load
  end

  describe "when loading facts from disk" do
    it "should be able to load files from disk and set facts" do
      data = {"f1" => "one", "f2" => "two"}
      file = File.join(@loader.directory, "data" + ".yaml")
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      @loader.load

      Facter.value("f1").should == "one"
      Facter.value("f2").should == "two"
    end

    it "should ignore files that begin with '.'" do
      file = File.join(@loader.directory, ".data.yaml")
      data = {"f1" => "one", "f2" => "two"}
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      @loader.load
      Facter.value("f1").should be_nil
    end

    %w{ttl bak orig}.each do |ext|
      it "should ignore files with an extension of '#{ext}'" do
        file = File.join(@loader.directory, "data" + ".#{ext}")
        File.open(file, "w") { |f| f.print "foo=bar" }

        @loader.load
      end
    end

    it "should throw a warning when trying to parse unknown file types" do
      file = File.join(@loader.directory, "file.unknownfiletype")
      File.open(file, "w") { |f| f.print "stuff=bar" }

      Facter.expects(:warn).with() { |v| v.match(/^Could not find parser for/) }
      @loader.load
    end

    it "should output a warning message when JSON file type returns nothing" do
      file = File.join(@loader.directory, "file.json")
      File.open(file, "w") { |f| f.print "{}" }

      Facter.expects(:warn).with() { |v| v.match(/^Fact file .+ was parsed but returned an empty data set/) }
      @loader.load
    end

    it "should output a warning message when txt file type returns nothing" do
      file = File.join(@loader.directory, "file.txt")
      File.open(file, "w") { |f| f.print "" }

      Facter.expects(:warn).with() { |v| v.match(/^Fact file .+ was parsed but returned an empty data set/) }
      @loader.load
    end

    it "should output a warning message when YAML file type returns nothing" do
      file = File.join(@loader.directory, "file.yaml")
      File.open(file, "w") { |f| f.print "" }

      Facter.expects(:warn).with() { |v| v.match(/^Fact file .+ was parsed but returned an empty data set/) }
      @loader.load
    end

    it "should use the cache when loading data" do
      cache_file = tmpfile
      Facter::Util::Config.cache_file = cache_file

      @loader = Facter::Util::DirectoryLoader.new(tmpdir)

      data = nil
      if Facter::Util::Config.is_windows?
        data = "@echo off
echo one=two
echo three=four
"
      else
        data = "#!/bin/sh
echo one=two
echo three=four
"
      end
      file = File.join(@loader.directory, "myscript.bat")

      File.open(file, "w") { |f| f.print data }
      File.chmod(0755, file)

      ttl_file = File.join(@loader.directory, "myscript.bat.ttl")
      File.open(ttl_file, "w") { |f| f.print "1" }
      
      Facter::Util::Cache.set(file,{"foo" => "bar"},1)
      Facter::Util::Cache.write!

      @loader.load

      # Make sure it's use the cache, not the disk
      Facter.value("foo").should == "bar"
    end
  end
end
