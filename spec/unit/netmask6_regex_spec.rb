#! /usr/bin/env ruby

require 'spec_helper'

describe "netmask6_regex" do
  include FacterSpec::ConfigHelper

  describe "on linux it should return different values for different paths" do
    it "like /sbin/ip" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ip')

      Facter.fact(:netmask6_regex).value.should ==
        /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end

    it "like /sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:netmask6_regex).value.should ==
        /inet6 addr: (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end
  end

  describe "on bsdlike and hp-ux" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
      :dragonfly ].each do |kernel|
      it "should return the same regex for #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)
        Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

        Facter.fact(:netmask6_regex).value.should ==
          /prefixlen (\w+)/
      end
    end
  end

  describe "on hp-ux" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:"hp-ux")
      Facter.fact(:ip_path).stubs(:value).returns('/bin/netstat')

      Facter.fact(:netmask6_regex).value.should ==
        /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end
  end

  describe "on sunos" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
      Facter.fact(:ip_path).stubs(:value).returns('/usr/sbin/ifconfig')

      Facter.fact(:netmask6_regex).value.should ==
        /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end
  end

  describe "on aix" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:aix)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:netmask6_regex).value.should ==
        /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end
  end

  describe "on windows" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:windows)

      Facter.fact(:netmask6_regex).value.should ==
        /Address\s+(?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}%(\d+)/
    end
  end
end
