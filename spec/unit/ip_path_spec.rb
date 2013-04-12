#! /usr/bin/env ruby

require 'spec_helper'

describe "ip_path" do
  include FacterSpec::ConfigHelper

  describe "on linux" do
    it "should return /sbin/ip if it's on the server" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      FileTest.stubs(:executable?).with('/sbin/ip').returns(true)
      FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(true)
      FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(false)

      Facter.fact(:ip_path).value.should == '/sbin/ip'
    end

    it "should return /sbin/ifconfig if /sbin/ip isn't there" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      FileTest.stubs(:executable?).with('/sbin/ip').returns(false)
      FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(true)
      FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(false)

      Facter.fact(:ip_path).value.should == '/sbin/ifconfig'
    end

    it "should fail if neither /sbin/ifconfig or /sbin/ip are available" do
      Facter.fact(:kernel).stubs(:value).returns(:linux)
      FileTest.stubs(:executable?).with('/sbin/ip').returns(false)
      FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(false)
      FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(false)

      Facter.fact(:ip_path).value.should == nil
    end
  end

  describe "on bsdlike" do
    [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly ].each { |kernel|
      it "should return /sbin/ifconfig on #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns(kernel)
        FileTest.stubs(:executable?).with('/sbin/ip').returns(false)
        FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(true)
        FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(false)

        Facter.fact(:ip_path).value.should == '/sbin/ifconfig'
      end
   }
  end

  describe "on sunos" do
    it "should return /usr/sbin/ifconfig" do
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
      FileTest.stubs(:executable?).with('/sbin/ip').returns(false)
      FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(false)
      FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(true)

      Facter.fact(:ip_path).value.should == '/usr/sbin/ifconfig'
    end
  end

  describe "on hp-ux" do
    it "should return /bin/netstat" do
      Facter.fact(:kernel).stubs(:value).returns(:"hp-ux")
      FileTest.stubs(:executable?).with('/sbin/ip').returns(false)
      FileTest.stubs(:executable?).with('/sbin/ifconfig').returns(false)
      FileTest.stubs(:executable?).with('/usr/sbin/ifconfig').returns(false)
      FileTest.stubs(:executable?).with('/bin/netstat').returns(true)

      Facter.fact(:ip_path).value.should == '/bin/netstat'
    end
  end

  describe "on windows" do
    it "should return netsh.exe" do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      FileTest.stubs(:executable?).with("#{ENV['SYSTEMROOT']}/system32/netsh.exe").returns(true)

      Facter.fact(:ip_path).value.should == "#{ENV['SYSTEMROOT']}/system32/netsh.exe"
    end
  end
end
