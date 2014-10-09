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

  let(:data) do {"one" => "two", "three" => "four"} end

  describe "yaml" do
    let(:data_in_yaml) { YAML.dump(data) }
    let(:data_file) { "/tmp/foo.yaml" }

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
    let(:data_in_json) { JSON.dump(data) }
    let(:data_file) { "/tmp/foo.json" }

    it "should return a hash of whatever is stored on disk" do
      pending("this test requires the json library") unless Facter.json?
      File.stubs(:read).with(data_file).returns(data_in_json)
      Facter::Util::Parser.parser_for(data_file).results.should == data
    end
  end

  describe "txt" do
    let(:data_file) { "/tmp/foo.txt" }

    shared_examples_for "txt parser" do
      it "should return a hash of whatever is stored on disk" do
        File.stubs(:read).with(data_file).returns(data_in_txt)
        Facter::Util::Parser.parser_for(data_file).results.should == data
      end
    end

    context "well formed data" do
      let(:data_in_txt) { "one=two\nthree=four\n" }
      it_behaves_like "txt parser"
    end

    context "extra equal sign" do
      let(:data_in_txt) { "one=two\nthree=four=five\n" }
      let(:data) do {"one" => "two", "three" => "four=five"} end
      it_behaves_like "txt parser"
    end

    context "extra data" do
      let(:data_in_txt) { "one=two\nfive\nthree=four\n" }
      it_behaves_like "txt parser"
    end
  end

  describe "scripts" do
    let(:ext) { Facter::Util::Config.is_windows? ? '.bat' : '.sh' }
    let(:cmd) { "/tmp/foo#{ext}" }
    let(:data_in_txt) { "one=two\nthree=four\n" }

    def expects_script_to_return(path, content, result)
      Facter::Core::Execution.stubs(:exec).with(path).returns(content)
      File.stubs(:executable?).with(path).returns(true)
      File.stubs(:file?).with(path).returns(true)

      Facter::Util::Parser.parser_for(path).results.should == result
    end

    def expects_parser_to_return_nil_for_directory(path)
      File.stubs(:file?).with(path).returns(false)

      Facter::Util::Parser.parser_for(path).results.should be_nil
    end

    it "returns a hash of whatever is returned by the executable" do
      expects_script_to_return(cmd, data_in_txt, data)
    end

    it "should not parse a directory" do
      expects_parser_to_return_nil_for_directory(cmd)
    end

    it "returns an empty hash when the script returns nil" do
      expects_script_to_return(cmd, nil, {})
    end

    it "quotes scripts with spaces" do
      path = "/h a s s p a c e s#{ext}"

      Facter::Core::Execution.expects(:exec).with("\"#{path}\"").returns(data_in_txt)

      expects_script_to_return(path, data_in_txt, data)
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

      it "should return script parser if on windows" do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
        cmds.each {|cmd| Facter::Util::Parser.parser_for(cmd).should be_an_instance_of(Facter::Util::Parser::ScriptParser) }
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

    describe "powershell parser" do
      let(:ps1) { "/tmp/foo.ps1" }

      def expects_to_parse_powershell(cmd, result)
        Facter::Util::Config.stubs(:is_windows?).returns(true)

        File.stubs(:file?).with(ps1).returns(true)

        Facter::Util::Parser.parser_for(cmd).results.should == result
      end

      it "should not parse a directory" do
        expects_parser_to_return_nil_for_directory(ps1)
      end

      it "should parse output from powershell" do
        Facter::Core::Execution.stubs(:exec).returns(data_in_txt)
        expects_to_parse_powershell(ps1, data)
      end

      describe "when executing powershell", :if => Facter::Util::Config.is_windows? do
        let(:sysnative_powershell) { "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe" }
        let(:system32_powershell)  { "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe" }

        let(:sysnative_regexp)  { /^\"#{Regexp.escape(sysnative_powershell)}\"/ }
        let(:system32_regexp)   { /^\"#{Regexp.escape(system32_powershell)}\"/ }
        let(:powershell_regexp) { /^\"#{Regexp.escape("powershell.exe")}\"/ }

        it "prefers the sysnative alias to resolve 64-bit powershell on 32-bit ruby" do
          File.expects(:exists?).with(sysnative_powershell).returns(true)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(sysnative_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end

        it "uses system32 if sysnative alias doesn't exist on 64-bit ruby" do
          File.expects(:exists?).with(sysnative_powershell).returns(false)
          File.expects(:exists?).with(system32_powershell).returns(true)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(system32_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end

        it "uses 'powershell' as a last resort" do
          File.expects(:exists?).with(sysnative_powershell).returns(false)
          File.expects(:exists?).with(system32_powershell).returns(false)
          Facter::Core::Execution.expects(:exec).with(regexp_matches(powershell_regexp)).returns(data_in_txt)

          expects_to_parse_powershell(ps1, data)
        end
      end
    end
  end

  describe "nothing parser" do
    it "uses the nothing parser when there is no other parser" do
      Facter::Util::Parser.parser_for("this.is.not.valid").results.should be_nil
    end
  end
end
