#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/parser'
require 'tempfile'
require 'json'

describe Facter::Util::Parser do
  include FacterSpec::Files

  it "should warn when asked to parse a file type it does not support" do
    Facter.expects(:warn)
    Facter::Util::Parser.new("/my/file.foobar")
  end

  describe "yaml" do
    subject { Facter::Util::Parser::YamlParser }
    it "should match the 'yaml' extension" do
      subject.extension.should == "yaml"
    end

    it "should return a hash of whatever is stored on disk" do
      file = tmpfile("yamlfile", "yaml")

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print YAML.dump(data) }

      Facter::Util::Parser.new(file).results.should == data
    end

    it "should return nil if YAML file is empty" do
      file = tmpfile("emptyyaml", "yaml")

      File.open(file, "w") { |f| f.print "" }

      Facter::Util::Parser.new(file).results.should == nil
    end

    it "should handle exceptions and warn" do
      file = tmpfile("exceptions", "yaml")

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print "}" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.new("/some/path/that/doesn't/exist.yaml").results }.should_not raise_error
    end
  end

  describe "json" do
    subject { Facter::Util::Parser::JsonParser }
    it "should match the 'json' extension" do
      subject.extension.should == "json"
    end

    it "should return a hash of whatever is stored on disk" do
      file = tmpfile("jsonfile", "json")

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print data.to_json }

      Facter::Util::Parser.new(file).results.should == data
    end

    it "should return an empty array if JSON file contains empty array" do
      file = tmpfile("emptyjson", "json")

      File.open(file, "w") { |f| f.print "{}" }

      Facter::Util::Parser.new(file).results.should == {}
    end

    it "should handle exceptions and warn if JSON content is invalid" do
      file = tmpfile("invalid", "json")

      File.open(file, "w") { |f| f.print "" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.new(file).results }.should_not raise_error
    end

  end

  describe "txt" do
    subject { Facter::Util::Parser::TextParser }
    it "should match the 'txt' extension" do
      subject.extension.should == "txt"
    end

    it "should return a hash of whatever is stored on disk" do
      file = tmpfile("txtfile", "txt")

      data = "one=two\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).results.should == {"one" => "two", "three" => "four"}
    end

    it "should return a nil if txt content is empty" do
      file = tmpfile("emptytxt", "txt")

      File.open(file, "w") { |f| f.print "" }

      Facter::Util::Parser.new(file).results.should == nil
    end

    it "should ignore any non-setting lines" do
      file = tmpfile("ignore", "txt")

      data = "one=two\nfive\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).results.should == {"one" => "two", "three" => "four"}
    end

    it "should ignore any extraneous whitespace" do
      file = tmpfile("whitespace", "txt")

      data = "one  =\ttwo  \n   three =four\t\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).results.should == {"one" => "two", "three" => "four"}
    end
  end

  describe "scripts" do
    before do
      @script = nil
      if Facter::Util::Config.is_windows?
        @script = tmpfile("script","bat")
        data = "@echo off
echo one=two
echo three=four
"

        File.open(@script, "w") { |f| f.print data }
      else
        @script = tmpfile("script","sh")
        data = "#!/bin/sh
echo one=two
echo three=four
"

        File.open(@script, "w") { |f| f.print data }
        File.chmod(0755, @script)
      end
    end

    it "should use any cache provided at initialization time" do
      cache_file = tmpfile
      cache = Facter::Util::Cache.new(cache_file)

      cache.stubs(:write!)
      cache[@script] = {"one" => "yay"}

      Facter::Util::Parser.new(@script, cache).results.should == {"one" => "yay"}
    end

    it "should return a hash directly from the executable when the cache is not primed" do
      cache_file = tmpfile
      cache = Facter::Util::Cache.new(cache_file)

      cache.stubs(:write!)

      Facter::Util::Parser.new(@script, cache).results.should == {"one" => "two", "three" => "four"}
    end

    it "should return a hash of whatever is returned by the executable" do
      Facter::Util::Parser.new(@script).results.should == {"one" => "two", "three" => "four"}
    end

    it "should ignore any extraneous whitespace" do
      my_script = nil
      if Facter::Util::Config.is_windows?
        my_script = tmpfile("script", "bat")
        data = "@echo off
echo one  =  two  
echo  three  = 	four  
"
        File.open(my_script, "w") { |f| f.print data }
      else
        my_script = tmpfile
        data = "#!/bin/sh
echo one  =  two  
echo  three  = 	four  
"
        File.open(my_script, "w") { |f| f.print data }
        File.chmod(0755, my_script)
      end

      Facter::Util::Parser.new(my_script).results.should == {"one" => "two", "three" => "four"}
    end

    it "should return a nil if script data returns nothing" do
      my_script = nil
      if Facter::Util::Config.is_windows?
        my_script = tmpfile("script","bat")
        data = "@echo off
echo =
"
        File.open(my_script, "w") { |f| f.print data }
      else
        my_script = tmpfile
        data = "#!/bin/sh
echo =
"
        File.open(my_script, "w") { |f| f.print data }
        File.chmod(0755, my_script)
      end

      my_parser = Facter::Util::Parser.new(my_script)
      my_parser.results.should == nil
    end

  end
end
