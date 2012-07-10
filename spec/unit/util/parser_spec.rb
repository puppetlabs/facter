#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/parser'
require 'tempfile'
require 'tmpdir.rb'

describe Facter::Util::Parser do
  include PuppetlabsSpec::Files

  describe "extension_matches? function" do
    it "should match extensions when subclass uses match_extension" do
      Facter::Util::Parser.extension_matches?("myfile.foobar", "foobar").should == true
    end

    it "should match extensions when subclass uses match_extension with an array" do
      Facter::Util::Parser.extension_matches?("myfile.ext1", ["ext1","ext2","ext3"]).should == true
      Facter::Util::Parser.extension_matches?("myfile.ext2", ["ext1","ext2","ext3"]).should == true
      Facter::Util::Parser.extension_matches?("myfile.ext3", ["ext1","ext2","ext3"]).should == true
    end

    it "should match extension ignoring case on file" do
      Facter::Util::Parser.extension_matches?("myfile.EXT1", "ext1").should == true
      Facter::Util::Parser.extension_matches?("myfile.ExT1", "ext1").should == true
      Facter::Util::Parser.extension_matches?("myfile.exT1", "ext1").should == true
    end

    it "should match extension ignoring case for match_extension" do
      Facter::Util::Parser.extension_matches?("myfile.EXT1", "EXT1").should == true
      Facter::Util::Parser.extension_matches?("myfile.ExT1", "EXT1").should == true
      Facter::Util::Parser.extension_matches?("myfile.exT1", "EXT1").should == true
    end
  end

  describe "yaml" do
    it "should return a hash of whatever is stored on disk" do
      file = tmpfilename('parser') + ".yaml"

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print YAML.dump(data) }

      Facter::Util::Parser.parser_for(file).results.should == data
    end

    it "should handle exceptions and warn" do
      file = tmpfilename('parser') + ".yaml"

      data = {"one" => "two", "three" => "four"}

      File.open(file, "w") { |f| f.print "}" }
      Facter.expects(:warn)
      lambda { Facter::Util::Parser.parser_for("/some/path/that/doesn't/exist.yaml").results }.should_not raise_error
    end
  end
  
  if Facter.json? 
    describe "json" do
      it "should return a hash of whatever is stored on disk" do
        file = tmpfilename('parser') + ".json"

        data = {"one" => "two", "three" => "four"}

        File.open(file, "w") { |f| f.print data.to_json }

        Facter::Util::Parser.parser_for(file).results.should == data
      end
    end
  end

  describe "txt" do
    it "should return a hash of whatever is stored on disk" do
      file = tmpfilename('parser') + ".txt"

      data = "one=two\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.parser_for(file).results.should == {"one" => "two", "three" => "four"}
    end

    it "should ignore any non-setting lines" do
      file = tmpfilename('parser') + ".txt"

      data = "one=two\nfive\nthree=four\n"

      File.open(file, "w") { |f| f.print data }

      Facter::Util::Parser.parser_for(file).results.should == {"one" => "two", "three" => "four"}
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
      Facter::Util::Parser.parser_for(@script).results.should == {"one" => "two", "three" => "four"}
    end

    it "should not parse a directory" do
      Dir.mktmpdir do |dir|
        Facter::Util::Parser.parser_for(dir).results.should == false
      end 
    end
  end
  
  describe "nothing parser" do
    it "uses the nothing parser when there is no other parser" do
      Facter::Util::Parser.parser_for("this.is.not.valid").results.should == false
    end
  end
end
