#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/ip'

describe Facter::IPAddress do

    it "should return a list of interfaces" do
       Facter::IPAddress.should respond_to(:get_interfaces)
    end

    it "should return an empty list of interfaces on an unknown kernel" do
        Facter.stubs(:value).returns("UnknownKernel")
        Facter::IPAddress.get_interfaces().should == []
    end

    it "should return a list with a single interface on Linux with a single interface" do
        sample_output_file = File.dirname(__FILE__) + '/../data/linux_ifconfig_all_with_single_interface'
        linux_ifconfig = File.new(sample_output_file).read()
        Facter::IPAddress.stubs(:get_all_interface_output).returns(linux_ifconfig)
        Facter::IPAddress.get_interfaces().should == ["eth0"]
    end

    it "should return a value for a specific interface" do
       Facter::IPAddress.should respond_to(:get_interface_value)
    end

end

