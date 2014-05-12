#! /usr/bin/env ruby

require 'spec_helper'

describe "Kernel release fact" do

  describe "on Windows" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("windows")
      require 'facter/util/wmi'
      version = stubs 'version'
      version.stubs(:Version).returns("test_kernel")
      Facter::Util::WMI.stubs(:execquery).with("SELECT Version from Win32_OperatingSystem").returns([version])
    end

    it "should return the kernel release" do
      Facter.fact(:kernelrelease).value.should == "test_kernel"
    end
  end

  describe "on AIX" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("aix")
      Facter::Core::Execution.stubs(:execute).with('oslevel -s', anything).returns("test_kernel")
    end

    it "should return the kernel release" do
      Facter.fact(:kernelrelease).value.should == "test_kernel"
    end
  end

  describe "on HP-UX" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("hp-ux")
      Facter::Core::Execution.stubs(:execute).with('uname -r').returns("B.11.31")
    end

    it "should remove preceding letters" do
      Facter.fact(:kernelrelease).value.should == "11.31"
    end
  end

  describe "on everything else" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("linux")
      Facter::Core::Execution.stubs(:execute).with('uname -r', anything).returns("test_kernel")
    end

    it "should return the kernel release" do
      Facter.fact(:kernelrelease).value.should == "test_kernel"
    end
  end

  describe 'on OpenBSD' do
    before do
      Facter.fact(:kernel).stubs(:value).returns :openbsd
    end

    it 'parses 5.3-current sysctl output' do
      Facter::Util::POSIX.stubs(:sysctl).with("kern.version").returns(my_fixture_read('openbsd-5.3-current'))
      Facter.value(:kernelrelease).should == '5.3-current'
    end

    it 'parses 5.3 sysctl output' do
      Facter::Util::POSIX.stubs(:sysctl).with("kern.version").returns(my_fixture_read('openbsd-5.3'))
      Facter.value(:kernelrelease).should == '5.3'
    end
  end
end
