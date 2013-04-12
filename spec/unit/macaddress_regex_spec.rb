#! /usr/bin/env ruby

require 'spec_helper'

describe "macaddress_regex" do
  include FacterSpec::ConfigHelper

  describe "on linux it should return different values for different paths" do
    it "like /sbin/ip" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ip')

      Facter.fact(:macaddress_regex).value.should ==
        /link\/ether (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
    end

    it "like /sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:macaddress_regex).value.should ==
        /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
    end
  end

  describe "on bsdlike, aix and sunos" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
      :dragonfly, :sunos ].each do |kernel|
      it "should return the same regex for #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)

        Facter.fact(:macaddress_regex).value.should ==
          /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
      end
    end
  end

  describe "on hp-ux" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:"hp-ux")

      Facter.fact(:macaddress_regex).value.should == /0x(\w+)/
    end
  end

  describe "on windows" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:windows)

      Facter.fact(:macaddress_regex).value.should ==
        //
    end
  end
end
