#! /usr/bin/env ruby

require 'spec_helper'

describe "netmask_regex" do
  include FacterSpec::ConfigHelper

  describe "on linux it should return different values for different paths" do
    it "like /sbin/ip" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ip')

      Facter.fact(:netmask_regex).value.should ==
        /inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/(\d+)/
    end

    it "like /sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:netmask_regex).value.should ==
        /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end

  describe "on bsdlike and hp-ux" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
      :dragonfly ].each do |kernel|
      it "should return the same regex for #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)
        Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

        Facter.fact(:netmask_regex).value.should ==
          /netmask 0x(\w+)/
      end
    end
  end

  describe "on hp-ux" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:"hp-ux")
      Facter.fact(:ip_path).stubs(:value).returns('/bin/netstat')

      Facter.fact(:netmask_regex).value.should ==
        /0x(\w+)/
    end
  end

  describe "on sunos" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
      Facter.fact(:ip_path).stubs(:value).returns('/usr/sbin/ifconfig')

      Facter.fact(:netmask_regex).value.should ==
      /netmask (\w+)/
    end
  end

  describe "on aix" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:aix)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:netmask_regex).value.should ==
      /netmask (\w+)/
    end
  end

  describe "on windows" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:windows)

      Facter.fact(:netmask_regex).value.should ==
        /mask ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end
end
