#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/parser'
require 'tempfile'
require 'facter/util/json'

describe Facter::Util::Parser do
  include PuppetlabsSpec::Files

  it "should fail when asked to parse a file type it does not support" do
    lambda { Facter::Util::Parser.new("/my/file.foobar") }.should raise_error(ArgumentError)
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
      file = tmpfilename('parser') + ".yaml"

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print YAML.dump(data) }

      Facter::Util::Parser.new(file).results.should == data
    end

    it "should handle exceptions and warn" do
      file = tmpfilename('parser') + ".yaml"

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print "}" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.new("/some/path/that/doesn't/exist.yaml").results }.should_not raise_error
    end
  end

  if Facter.json? 
    describe "json" do
      subject { Facter::Util::Parser::JsonParser }
      it "should match the 'json' extension" do
        subject.extension.should == "json"
      end

      it "should return a hash of whatever is stored on disk" do
        file = tmpfilename('parser') + ".json"

        data = {"one" => "two", "three" => "four"}

        File.open(file, "w") { |f| f.print data.to_json }

        Facter::Util::Parser.new(file).results.should == data
      end
    end

    describe "json" do
      subject { Facter::Util::Parser::JsonParser }
      it "should match the 'json' extension" do
        subject.extension.should == "json"
      end

      it "should return a hash of whatever is stored on disk" do
        file = tmpfilename('parser') + ".json"

        data = {"one" => "two", "three" => "four"}

        File.open(file, "w") { |f| f.print data.to_json }

        Facter::Util::Parser.new(file).results.should == data
      end
    end
  end

  describe "txt" do
    subject { Facter::Util::Parser::TextParser }
    it "should match the 'txt' extension" do
      subject.extension.should == "txt"
    end

    it "should return a hash of whatever is stored on disk" do
      file = tmpfilename('parser') + ".txt"

      data = "one=two\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).results.should == {"one" => "two", "three" => "four"}
    end

    it "should ignore any non-setting lines" do
      file = tmpfilename('parser') + ".txt"

      data = "one=two\nfive\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.new(file).results.should == {"one" => "two", "three" => "four"}
    end
  end

  describe "scripts" do
    before do
      @script = tmpfilename('parser')
      data = "#!/bin/sh
echo one=two
echo three=four
"

      File.open(@script, "w") { |f| f.print data }
      File.chmod(0755, @script)
    end

    it "should return a hash of whatever is returned by the executable" do
      Facter::Util::Parser.new(@script).results.should == {"one" => "two", "three" => "four"}
    end
  end
end
