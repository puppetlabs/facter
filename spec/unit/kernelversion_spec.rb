#! /usr/bin/env ruby

require 'spec_helper'

describe "Kernel version fact" do

  describe "on Solaris/Sun OS" do
    before do
      Facter.fact(:kernel).stubs(:value).returns('sunos')
      Facter::Core::Execution.stubs(:execute).with('uname -v', anything).returns("1.234.5")
    end

    it "should return the kernel version using 'uname -v'" do
      Facter.fact(:kernelversion).value.should == "1.234.5"
    end
  end

  describe "on everything else" do
    before do
      Facter.fact(:kernel).stubs(:value).returns('linux')
      Facter.fact(:kernelrelease).stubs(:value).returns('1.23.4-56')
    end

    it "should return the kernel version using kernel release" do
      Facter.fact(:kernelversion).value.should == "1.23.4"
    end
  end
end




