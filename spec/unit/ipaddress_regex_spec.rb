#! /usr/bin/env ruby

require 'spec_helper'

describe "ipaddress_regex" do
  include FacterSpec::ConfigHelper

  describe "on linux it should return different values for different paths" do
    it "like /sbin/ip" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ip')

      Facter.fact(:ipaddress_regex).value.should ==
        /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end

    it "like /sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

      Facter.fact(:ipaddress_regex).value.should ==
        /inet addr: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end

  describe "on bsdlike and aix" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
      :dragonfly, :aix ].each do |kernel|
      it "should return the same regex for #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)
        Facter.fact(:ip_path).stubs(:value).returns('/sbin/ifconfig')

        Facter.fact(:ipaddress_regex).value.should ==
          /inet addr: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
      end
    end
  end

  describe "on sunos" do
    Facter.fact(:kernel).stubs(:value).returns(:sunos)
    Facter.fact(:ip_path).stubs(:value).returns('/usr/sbin/ifconfig')

    Facter.fact(:ipaddress_regex).value.should ==
      /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
  end

  describe "on windows" do
    it "should return a regex" do
      Facter.fact(:kernel).stubs(:value).returns(:windows)

      Facter.fact(:ipaddress_regex).value.should ==
        /IP Address:\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end
end
