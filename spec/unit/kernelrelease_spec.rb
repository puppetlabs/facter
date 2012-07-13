#! /usr/bin/env ruby -S rspec

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
      Facter::Util::Resolution.stubs(:exec).with('oslevel -s').returns("test_kernel")
    end 
    
    it "should return the kernel release" do 
      Facter.fact(:kernelrelease).value.should == "test_kernel"
    end 
  end 

  describe "on HP-UX" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("hp-ux") 
      Facter::Util::Resolution.stubs(:exec).with('uname -r').returns("B.11.31")
    end 
    
    it "should remove preceding letters" do
      Facter.fact(:kernelrelease).value.should == "11.31"
    end 
  end 

  describe "on everything else" do 
    before do
      Facter.fact(:kernel).stubs(:value).returns("linux")
      Facter::Util::Resolution.stubs(:exec).with('uname -r').returns("test_kernel")
    end 
    
    it "should return the kernel release" do
      Facter.fact(:kernelrelease).value.should == "test_kernel"
    end   
  end   
end 
