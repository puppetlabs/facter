require 'spec_helper'
require 'facter/util/parser'
require 'tempfile'
require 'tmpdir'

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

  let(:data) do {"one" => "two", "three" => "four"} end

  describe "yaml" do
    let(:data_in_yaml) do YAML.dump(data) end
    let(:data_file) do "/tmp/foo.yaml" end

    it "should return a hash of whatever is stored on disk" do
      File.stubs(:read).with(data_file).returns(data_in_yaml)
      described_class.parser_for(data_file).results.should == data
    end

    it "should handle exceptions and warn" do
      # YAML data with an error
      File.stubs(:read).with(data_file).returns(data_in_yaml + "}")
      Facter.expects(:warn).at_least_once
      lambda { Facter::Util::Parser.parser_for(data_file).results }.should_not raise_error
    end
  end

  describe "json" do
    let(:data_in_json) do JSON.dump(data) end
    let(:data_file) do "/tmp/foo.json" end

    it "should return a hash of whatever is stored on disk" do
      pending("this test requires the json library") unless Facter.json?
      File.stubs(:read).with(data_file).returns(data_in_json)
      Facter::Util::Parser.parser_for(data_file).results.should == data
    end
  end

  describe "txt" do
    let(:data_file) do "/tmp/foo.txt" end

    shared_examples_for "txt parser" do
      it "should return a hash of whatever is stored on disk" do
        File.stubs(:read).with(data_file).returns(data_in_txt)
        Facter::Util::Parser.parser_for(data_file).results.should == data
      end
    end

    context "well formed data" do
      let(:data_in_txt) do "one=two\nthree=four\n" end
      it_behaves_like "txt parser"
    end
    
    context "extra equal sign" do
      let(:data_in_txt) do "one=two\nthree=four=five\n" end
      let(:data) do {"one" => "two", "three" => "four=five"} end
      it_behaves_like "txt parser"
    end

    context "extra data" do
      let(:data_in_txt) do "one=two\nfive\nthree=four\n" end
      it_behaves_like "txt parser"
    end
  end

  describe "scripts" do
    let :cmd do "/tmp/foo.sh" end
    let :data_in_txt do "one=two\nthree=four\n" end

    before :each do
      Facter::Util::Resolution.stubs(:exec).with(cmd).returns(data_in_txt)
      File.stubs(:executable?).with(cmd).returns(true)
    end

    it "should return a hash of whatever is returned by the executable" do
      pending("this test does not run on windows") if Facter::Util::Config.is_windows?
      File.stubs(:file?).with(cmd).returns(true)
      Facter::Util::Parser.parser_for(cmd).results.should == data
    end

    it "should not parse a directory" do
      File.stubs(:file?).with(cmd).returns(false)
      Facter::Util::Parser.parser_for(cmd).results.should be_nil
    end

    context "on Windows" do
      let :cmd do "/tmp/foo.bat" end

      before :each do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
      end

      let :parser do
        Facter::Util::Parser.parser_for(cmd)
      end

      it "should not parse a directory" do
        File.stubs(:file?).with(cmd).returns(false)
        Facter::Util::Parser.parser_for(cmd).results.should be_nil
      end

      it "should return the data properly" do
        File.stubs(:file?).with(cmd).returns(true)
        parser.results.should == data
      end
    end

    context "exe, bat, cmd, and com files" do
      let :cmds do ["/tmp/foo.bat", "/tmp/foo.cmd", "/tmp/foo.exe", "/tmp/foo.com"] end

      before :each do
        cmds.each {|cmd|
          File.stubs(:executable?).with(cmd).returns(true)
          File.stubs(:file?).with(cmd).returns(true)
        }
      end

      it "should return nothing parser if not on windows" do
        Facter::Util::Config.stubs(:is_windows?).returns(false)
        cmds.each {|cmd| Facter::Util::Parser.parser_for(cmd).should be_an_instance_of(Facter::Util::Parser::NothingParser) }
      end

      it "should return script  parser if on windows" do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
        cmds.each {|cmd| Facter::Util::Parser.parser_for(cmd).should be_an_instance_of(Facter::Util::Parser::ScriptParser) }
      end

     end
  end

  describe "powershell parser" do
    let :ps1 do "/tmp/foo.ps1" end
    let :data_in_ps1 do "one=two\nthree=four\n" end

    before :each do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      Facter::Util::Resolution.stubs(:exec).returns(data_in_ps1)
    end

    let :parser do
      Facter::Util::Parser.parser_for(ps1)
    end

    it "should not parse a directory" do
      File.stubs(:file?).with(ps1).returns(false)
      Facter::Util::Parser.parser_for(ps1).results.should be_nil
    end

    it "should return data properly" do
      File.stubs(:file?).with(ps1).returns(true)
      parser.results.should == data
    end
  end

  describe "nothing parser" do
    it "uses the nothing parser when there is no other parser" do
      Facter::Util::Parser.parser_for("this.is.not.valid").results.should be_nil
    end
  end
end
