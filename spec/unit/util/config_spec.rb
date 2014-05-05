#! /usr/bin/env ruby

require 'spec_helper'

describe Facter::Util::Config do
  include PuppetlabsSpec::Files

  describe "is_windows? function" do
    it "should detect windows if Ruby RbConfig::CONFIG['host_os'] returns a windows OS" do
      host_os = ["mswin","win32","dos","mingw","cygwin"]
      host_os.each do |h|
        RbConfig::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_true
      end
    end

    it "should not detect windows if Ruby RbConfig::CONFIG['host_os'] returns a non-windows OS" do
      host_os = ["darwin","linux"]
      host_os.each do |h|
        RbConfig::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_windows?.should be_false
      end
    end
  end

  describe "is_mac? function" do
    it "should detect mac if Ruby RbConfig::CONFIG['host_os'] returns darwin" do
      host_os = ["darwin"]
      host_os.each do |h|
        RbConfig::CONFIG.stubs(:[]).with('host_os').returns(h)
        Facter::Util::Config.is_mac?.should be_true
      end
    end
  end

  describe "external_facts_dirs" do
    before :each do
      Facter::Util::Root.stubs(:root?).returns(true)
    end

    it "should return the default value for linux" do
      Facter::Util::Config.stubs(:is_windows?).returns(false)
      Facter::Util::Config.stubs(:windows_data_dir).returns(nil)
      Facter::Util::Config.setup_default_ext_facts_dirs
      Facter::Util::Config.external_facts_dirs.should == ["/etc/facter/facts.d", "/etc/puppetlabs/facter/facts.d"]
    end

    it "should return the default value for windows 2008" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      Facter::Util::Config.stubs(:windows_data_dir).returns("C:\\ProgramData")
      Facter::Util::Config.setup_default_ext_facts_dirs
      Facter::Util::Config.external_facts_dirs.should == [File.join("C:\\ProgramData", 'PuppetLabs', 'facter', 'facts.d')]
    end

    it "should return the default value for windows 2003R2" do
      Facter::Util::Config.stubs(:is_windows?).returns(true)
      Facter::Util::Config.stubs(:windows_data_dir).returns("C:\\Documents")
      Facter::Util::Config.setup_default_ext_facts_dirs
      Facter::Util::Config.external_facts_dirs.should == [File.join("C:\\Documents", 'PuppetLabs', 'facter', 'facts.d')]
    end

    it "returns the users home directory when not root" do
      Facter::Util::Root.stubs(:root?).returns(false)
      Facter::Util::Config.setup_default_ext_facts_dirs
      Facter::Util::Config.external_facts_dirs.should == [File.expand_path(File.join("~", ".facter", "facts.d"))]
    end

    it "includes additional values when user appends to the list" do
      Facter::Util::Config.setup_default_ext_facts_dirs
      original_values = Facter::Util::Config.external_facts_dirs.dup
      new_value = '/usr/share/newdir'
      Facter::Util::Config.external_facts_dirs << new_value
      Facter::Util::Config.external_facts_dirs.should == original_values + [new_value]
    end

    it "should only output new values when explicitly set" do
      Facter::Util::Config.setup_default_ext_facts_dirs
      new_value = ['/usr/share/newdir']
      Facter::Util::Config.external_facts_dirs = new_value
      Facter::Util::Config.external_facts_dirs.should == new_value
    end

  end
end
