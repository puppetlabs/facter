#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Per Interface IP facts" do
    before do
        Facter.loadfacts
    end

    it "should replace the ':' in an interface list with '_'" do
        # So we look supported
        Facter.fact(:kernel).stubs(:value).returns("SunOS")

        Facter::Util::IP.expects(:get_interfaces).returns %w{eth0:1 eth1:2}
        Facter.fact(:interfaces).value.should == %{eth0_1,eth1_2}
    end
end
