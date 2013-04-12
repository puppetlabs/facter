#! /usr/bin/env ruby

require 'spec_helper'

describe "mtu_regex" do
  include FacterSpec::ConfigHelper

  describe "on linux it should return different values for different paths" do
    it "like /sbin/ip" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ip')

      Facter.fact(:mtu_regex).value.should ==
        /mtu (\d+)/
    end

    it "like /sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:mtu_regex).value.should ==
        /MTU:(\d+)/
    end
  end

  describe "on bsdlike and aix" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
      :dragonfly, :aix, :sunos, :"hp-ux" ].each do |kernel|
      it "should return the same regex for #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)

        Facter.fact(:mtu_regex).value.should ==
          /mtu\s+(\d+)/
      end
    end
  end

end
