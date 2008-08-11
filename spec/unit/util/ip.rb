#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/ip'

describe Facter::IPAddress do

    it "should return a list of interfaces" do
       Facter::IPAddress.should respond_to(:get_interfaces)
    end

    it "should return a value for a specific interface" do
       Facter::IPAddress.should respond_to(:get_interface_value)
    end

end

