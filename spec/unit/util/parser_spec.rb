#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/parser'
require 'tempfile'
require 'json'

describe Facter::Util::Parser do
  include PuppetlabsSpec::Files

  it "should fail when asked to parse a file type it does not support" do
    lambda { Facter::Util::Parser.new("/my/file.foobar") }.should raise_error(ArgumentError)
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
