#! /usr/bin/env ruby

require 'spec_helper'

describe "Hostname facts" do

  describe "on linux" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:kernelrelease).stubs(:value).returns("2.6")
    end

    it "should use the hostname command" do
      Facter::Core::Execution.expects(:execute).with('hostname').at_least_once
      Facter.fact(:hostname).value.should be_nil
    end

    it "should use hostname as the fact if unqualified" do
      Facter::Core::Execution.stubs(:execute).with('hostname').returns('host1')
      Facter.fact(:hostname).value.should == "host1"
    end

    it "should truncate the domain name if qualified" do
      Facter::Core::Execution.stubs(:execute).with('hostname').returns('host1.example.com')
      Facter.fact(:hostname).value.should == "host1"
    end
  end

  describe "on darwin release R7" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      Facter.fact(:kernelrelease).stubs(:value).returns("R7")
    end

    it "should use scutil to get the hostname" do
      Facter::Core::Execution.expects(:execute).with('/usr/sbin/scutil --get LocalHostName', anything).returns("host1")
      Facter.fact(:hostname).value.should == "host1"
    end
  end
end
