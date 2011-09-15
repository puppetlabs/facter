#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'
require 'facter/util/ip'

describe "Per Interface IP facts" do
    it "should replace the ':' in an interface list with '_'" do
        # So we look supported
        Facter.fact(:kernel).stubs(:value).returns("SunOS")

        Facter::Util::IP.stubs(:get_interfaces).returns %w{eth0:1 eth1:2}
        Facter.fact(:interfaces).value.should == %{eth0_1,eth1_2}
    end
end
