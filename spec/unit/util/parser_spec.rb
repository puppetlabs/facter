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

  describe "when determining TTL" do

    # Temporary data file
    let(:data_file) { File.join(tmpdir, "mydata.txt") }

    # The corresponding TTL file for the data file
    let(:ttl_file) { data_file + ".ttl" }

    # Parser object initialized with the data_file
    let(:parser) { Facter::Util::Parser.new(data_file) }

    it "should determine TTL by looking in a file named after the external fact file with a '.ttl' extension" do
      File.open(ttl_file, "w") { |f| f.print 300 }

      parser.ttl.should == 300
    end

    it "should support a -1 for TTL" do
      File.open(ttl_file, "w") { |f| f.print -1 }

      parser.ttl.should == -1
    end

    it "should return 0 when ttl file doesn't contain a number" do
      File.open(ttl_file, "w") { |f| f.print "some weird data" }

      parser.ttl.should == 0
    end

    it "should return 0 when no ttl file is provided" do
      parser.ttl.should == 0
    end
  end

  describe "values function" do
    it "should output timing when results are requested" do
      file = tmpfile("timing","txt") 
      File.open(file, "w") { |f| f.print "abc=def" }
  
      Facter.expects(:show_time)
      Facter::Util::Parser.new(file).values.should == {"abc"=>"def"}
    end

    it "should raise an error when results method is not overwritten in a subclass" do
      class TestParser < Facter::Util::Parser
        matches_extension "foobar"
      end

      file = tmpfile("timing","foobar") 
      File.open(file, "w") { |f| f.print "abc=def" }

      lambda { Facter::Util::Parser.new(file).values }.should raise_error
    end
  end

  describe "matches? function" do
    it "should match extensions when subclass uses match_extension" do
      class TestParser < Facter::Util::Parser
        matches_extension "foobar"
      end

      TestParser.matches?("myfile.foobar").should == true
    end

    it "should match extensions when subclass uses match_extension with an array" do
      class TestParser < Facter::Util::Parser
        matches_extension ["ext1","ext2","ext3"]
      end

      TestParser.matches?("myfile.ext1").should == true
      TestParser.matches?("myfile.ext2").should == true
      TestParser.matches?("myfile.ext3").should == true
    end

    it "should match extension ignoring case on file" do
      class TestParser < Facter::Util::Parser
        matches_extension "ext1"
      end

      TestParser.matches?("myfile.EXT1").should == true
      TestParser.matches?("myfile.ExT1").should == true
      TestParser.matches?("myfile.exT1").should == true
    end

    it "should match extension ignoring case for match_extension" do
      class TestParser < Facter::Util::Parser
        matches_extension "EXT1"
      end

      TestParser.matches?("myfile.EXT1").should == true
      TestParser.matches?("myfile.ExT1").should == true
      TestParser.matches?("myfile.exT1").should == true
    end

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

      Facter::Util::Parser.new(file).values.should == data
    end

    it "should return nil if YAML file is empty" do
      file = tmpfile("emptyyaml", "yaml")

      File.open(file, "w") { |f| f.print "" }

      Facter::Util::Parser.new(file).values.should == nil
    end

    it "should handle exceptions and warn" do
      file = tmpfile("exceptions", "yaml")

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print "}" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.new("/some/path/that/doesn't/exist.yaml").values }.should_not raise_error
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

      Facter::Util::Parser.new(file).values.should == data
    end

    it "should return an empty array if JSON file contains empty array" do
      file = tmpfile("emptyjson", "json")

      File.open(file, "w") { |f| f.print "{}" }

      Facter::Util::Parser.new(file).values.should == {}
    end

    it "should handle exceptions and warn if JSON content is invalid" do
      file = tmpfile("invalid", "json")

      File.open(file, "w") { |f| f.print "" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.new(file).values }.should_not raise_error
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

      Facter::Util::Parser.new(file).values.should == {"one" => "two", "three" => "four"}
    end

    it "should return a nil if txt content is empty" do
      file = tmpfile("emptytxt", "txt")

      File.open(file, "w") { |f| f.print "" }

      Facter::Util::Parser.new(file).values.should == nil
    end

    it "should ignore any non-setting lines" do
      file = tmpfile("ignore", "txt")

      data = "one=two\nfive\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).values.should == {"one" => "two", "three" => "four"}
    end

    it "should ignore any extraneous whitespace" do
      file = tmpfile("whitespace", "txt")

      data = "one  =\ttwo  \n   three =four\t\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).values.should == {"one" => "two", "three" => "four"}
    end
  end

  describe "scripts" do
    subject { Facter::Util::Parser::ScriptParser }

    let(:script_file) do
      if Facter::Util::Config.is_windows?
        tmpfile("script","bat")
      else 
        tmpfile("script","sh")
      end
    end

    before :each do
      if Facter::Util::Config.is_windows?
        data = "@echo off
echo one=two
echo three=four
"

        File.open(script_file, "w") { |f| f.print data }
      else
        data = "#!/bin/sh
echo one=two
echo three=four
"

        File.open(script_file, "w") { |f| f.print data }
        File.chmod(0755, script_file)
      end
    end 

    it "should use any cache provided at initialization time" do
      Facter::Util::Config.cache_file = tmpfile
      Facter::Util::Cache.set(script_file, {"one" => "yay"}, 1)

      parser = Facter::Util::Parser.new(script_file)
      parser.expects(:ttl).once.returns(1)
      parser.values.should == {"one" => "yay"}
    end

    it "should return a hash directly from the executable when the cache is not primed" do
      cache_file = tmpfile
      Facter::Util::Config.cache_file = cache_file

      Facter::Util::Cache.any_instance.stubs(:write!)

      Facter::Util::Parser.new(script_file).values.should == {"one" => "two", "three" => "four"}
    end

    it "should return a hash of whatever is returned by the executable" do
      Facter::Util::Parser.new(script_file).values.should == {"one" => "two", "three" => "four"}
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

      Facter::Util::Parser.new(my_script).values.should == {"one" => "two", "three" => "four"}
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
      my_parser.values.should == nil
    end

    it "should match the extensions bat, exe & com", :if => Facter::Util::Config.is_windows? do
      subject.extension.should == %w{bat com exe}
    end
  end

  describe "powershell", :if => Facter::Util::Config.is_windows? do
    subject { Facter::Util::Parser::PowershellParser }

    let(:script_file) { tmpfile("script","ps1") }

    before :each do
      data = <<EOS
Write-Host "var1=value1"
Write-Host "var2=value2"
Write-Host "var3=value3"
EOS

      File.open(script_file, "w") { |f| f.print data }
    end

    it "should use any cache provided at initialization time" do
      cache_file = tmpfile
      Facter::Util::Config.cache_file = cache_file
      Facter::Util::Cache.set(script_file,{"one" => "yay"},1)

      parser = Facter::Util::Parser.new(script_file)
      parser.expects(:ttl).returns(1)
      parser.values.should == {"one" => "yay"}
    end

    it "should return a hash directly from the executable when the cache is not primed" do
      cache_file = tmpfile
      Facter::Util::Config.cache_file = cache_file

      Facter::Util::Cache.any_instance.stubs(:write!)

      Facter::Util::Parser.new(script_file).values.should == {"var1" => "value1", "var2" => "value2", "var3" => "value3"}
    end

    it "should return a hash of whatever is returned by the executable" do
      Facter::Util::Parser.new(script_file).values.should == {"var1" => "value1", "var2" => "value2", "var3" => "value3"}
    end

    it "should ignore any extraneous whitespace" do
      my_script = tmpfile("script", "ps1")
      data = <<EOS
Write-Host "   var1 	= value1"
Write-Host "var2   	= 	value2  "
Write-Host "var3=  value3   "
EOS
      File.open(my_script, "w") { |f| f.print data }

      Facter::Util::Parser.new(my_script).values.should == {"var1" => "value1", "var2" => "value2", "var3" => "value3"}
    end

    it "should return a nil if script data returns nothing" do
      my_script = tmpfile("script","ps1")
      data = ""
      File.open(my_script, "w") { |f| f.print data }

      my_parser = Facter::Util::Parser.new(my_script)
      my_parser.values.should == nil
    end

    it "should match the extensions ps1" do
      subject.extension.should == "ps1"
    end

    it "should handle script paths with spaces" do
      my_script = tmpfile("script with space","ps1")
      data = "Write-Host foo=bar"
      File.open(my_script, "w") { |f| f.print data }

      my_parser = Facter::Util::Parser.new(my_script)
      my_parser.values.should == {"foo"=>"bar"}
    end

    it "should match the extensions ps1" do
      subject.extension.should == "ps1"
    end

  end
end
