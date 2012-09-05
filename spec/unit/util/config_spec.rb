#!/usr/bin/env ruby -S rspec

require 'spec_helper'
require 'rspec/mocks'

describe Facter::Util::Config do
  include PuppetlabsSpec::Files

  describe "is_windows? function" do
    it "should detect windows if Ruby Config::CONFIG['host_os'] returns a windows OS" do
      host_os = ["mswin","win32","dos","mingw","cygwin"]
      host_os.each do |h|
        Config::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_true
      end
    end

    it "should not detect windows if Ruby Config::CONFIG['host_os'] returns a non-windows OS" do
      host_os = ["darwin","linux"]
      host_os.each do |h|
        Config::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_false
      end
    end
  end

  describe "is_mac? function" do
    it "should detect mac if Ruby Config::CONFIG['host_os'] returns darwin" do
      host_os = ["darwin"]
      host_os.each do |h|
        Config::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_mac?.should be_true
      end
    end
  end

  describe "external_facts_dirs" do
    
    describe "Environment variables set to directories" do
      it "should return directories for both linux and windows" do
        ENV["FACTER_PATH"] = ["/test1", "/test2"].join File::PATH_SEPARATOR
        Facter::Util::Config.external_facts_dirs.should == ["/test1", "/test2"]
      end
    end
    
    describe "Environment variables not set" do
      
      before :each do
        ENV["FACTER_PATH"] = nil
      end
      
      it "should return the default value for linux" do
        Facter::Util::Config.stubs(:is_windows?).returns(false)
        Facter::Util::Config.stubs(:windows_data_dir).returns(nil)
        Facter::Util::Config.external_facts_dirs.should == ["/etc/facter/facts.d", "/etc/puppetlabs/facter/facts.d"]
      end

      it "should return the default value for windows 2008" do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
        Facter::Util::Config.stubs(:windows_data_dir).returns("C:\\ProgramData")
        Facter::Util::Config.external_facts_dirs.should == [File.join("C:\\ProgramData", 'PuppetLabs', 'facter', 'facts.d')]
      end

      it "should return the default value for windows 2003R2" do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
        Facter::Util::Config.stubs(:windows_data_dir).returns("C:\\Documents and Settings")
        Facter::Util::Config.external_facts_dirs.should == [File.join("C:\\Documents and Settings", 'PuppetLabs', 'facter', 'facts.d')]
      end
    end
    
    describe "Environment variable is set to empty string" do
      
      before :each do
        ENV["FACTER_PATH"] = ""
      end
      
      it "should return an empty set on linux" do
        Facter::Util::Config.stubs(:is_windows?).returns(false)
        Facter::Util::Config.stubs(:windows_data_dir).returns(nil)
        Facter::Util::Config.external_facts_dirs.should == []
      end
      
      it "should return an empty set on windows 2008" do
        Facter::Util::Config.stubs(:is_windows?).returns(true)
        Facter::Util::Config.stubs(:windows_data_dir).returns("C:\\Documents and Settings")
        Facter::Util::Config.external_facts_dirs.should == []
      end
    end
    
  end
end
