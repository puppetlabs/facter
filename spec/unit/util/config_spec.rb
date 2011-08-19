#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/cache'

describe Facter::Util::Config do
  include FacterSpec::Files

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

  describe "cache_file attribute" do
    around :each do |example|
      Facter::Util::Config.cache_file = nil
      example.run
      Facter::Util::Config.cache_file = nil
    end

    it "should allow setting and getting" do
      filename = tmpfile
      Facter::Util::Config.cache_file = filename
      Facter::Util::Config.cache_file.should == filename
    end

    it "should return the default value for mac" do
      Facter::Util::Config.stubs(:is_windows?).returns(false)
      Facter::Util::Config.stubs(:is_mac?).returns(true)
      Facter::Util::Config.cache_file.should == "/var/db/facter_cache.dat"
    end

    it "should return the default value for linux" do
      Facter::Util::Config.stubs(:is_windows?).returns(false)
      Facter::Util::Config.stubs(:is_mac?).returns(false)
      Facter::Util::Config.cache_file.should == "/var/cache/facter_cache.dat"
    end

    it "should return the default value for windows 2008" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      ENV.stubs(:[]).with("ProgramData").returns("C:\\ProgramData")
      Facter::Util::Config.cache_file.should == "C:\\ProgramData/Puppetlabs/facter/cache/facter_cache.dat"
    end

    it "should return the default value for windows 2003R2" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      ENV.stubs(:[]).with("ProgramData").returns(nil)
      ENV.stubs(:[]).with("ALLUSERSPROFILE").returns("C:\\Documents and Settings\\All Users")
      Facter::Util::Config.cache_file.should == "C:\\Documents and Settings\\All Users/Application Data/Puppetlabs/facter/cache/facter_cache.dat"
    end
  end

  describe "ext_fact_dir attribute" do
    around :each do |example|
      Facter::Util::Config.ext_fact_dir = nil
      example.run
      Facter::Util::Config.ext_fact_dir = nil
    end
 
    it "should allow setting and getting" do
      filename = tmpfile
      Facter::Util::Config.ext_fact_dir = filename
      Facter::Util::Config.ext_fact_dir.should == filename
    end

    it "should return the default value for linux" do
      Facter::Util::Config.stubs(:is_windows?).returns(false)
      Facter::Util::Config.ext_fact_dir.should == "/usr/lib/facter/ext"
    end

    it "should return the default value for windows 2008" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      ENV.stubs(:[]).with("ProgramData").returns("C:\\ProgramData")
      Facter::Util::Config.ext_fact_dir.should == "C:\\ProgramData/Puppetlabs/facter/ext"
    end

    it "should return the default value for windows 2003R2" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      ENV.stubs(:[]).with("ProgramData").returns(nil)
      ENV.stubs(:[]).with("ALLUSERSPROFILE").returns("C:\\Documents and Settings\\All Users")
      Facter::Util::Config.ext_fact_dir.should == "C:\\Documents and Settings\\All Users/Application Data/Puppetlabs/facter/ext"
    end
  end

end
