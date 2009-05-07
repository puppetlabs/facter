#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/ip'

describe Facter::Util::IP do
    [:freebsd, :linux, :netbsd, :openbsd, :sunos, :darwin].each do |platform|
        it "should be supported on #{platform}" do
            Facter::Util::IP.supported_platforms.should be_include(platform)
        end
    end

    it "should return a list of interfaces" do
        Facter::Util::IP.should respond_to(:get_interfaces)
    end

    it "should return an empty list of interfaces on an unknown kernel" do
        Facter.stubs(:value).returns("UnknownKernel")
        Facter::Util::IP.get_interfaces().should == []
    end

    it "should return a list with a single interface on Linux with a single interface" do
        sample_output_file = File.dirname(__FILE__) + '/../data/linux_ifconfig_all_with_single_interface'
        linux_ifconfig = File.new(sample_output_file).read()
        Facter::Util::IP.stubs(:get_all_interface_output).returns(linux_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["eth0"]
    end

    it "should return a list two interfaces on Darwin with two interfaces" do
        sample_output_file = File.dirname(__FILE__) + '/../data/darwin_ifconfig_all_with_multiple_interfaces'
        darwin_ifconfig = File.new(sample_output_file).read()
        Facter::Util::IP.stubs(:get_all_interface_output).returns(darwin_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["lo0", "en0"]
    end

    it "should return a value for a specific interface" do
        Facter::Util::IP.should respond_to(:get_interface_value)
    end

    it "should not return interface information for unsupported platforms" do
        Facter.stubs(:value).with(:kernel).returns("bleah")
        Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == []
    end

    it "should return ipaddress information for Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "ipaddress").should == "172.16.15.138"
    end

    it "should return netmask information for Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
    end

    it "should return interface information for FreeBSD supported via an alias" do
        sample_output_file = File.dirname(__FILE__) + "/../data/6.0-STABLE_FreeBSD_ifconfig"
        ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("fxp0").returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("FreeBSD")

        Facter::Util::IP.get_interface_value("fxp0", "macaddress").should == "00:0e:0c:68:67:7c"
    end

    it "should return macaddress information for OS X" do
        sample_output_file = File.dirname(__FILE__) + "/../data/Mac_OS_X_10.5.5_ifconfig"
        ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interface_value("en1", "macaddress").should == "00:1b:63:ae:02:66"
    end

    it "should return all interfaces correctly on OS X" do
        sample_output_file = File.dirname(__FILE__) + "/../data/Mac_OS_X_10.5.5_ifconfig"
        ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_all_interface_output).returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interfaces().should == ["lo0", "gif0", "stf0", "en0", "fw0", "en1", "vmnet8", "vmnet1"]
    end

    it "should return a human readable netmask on Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
    end

    it "should return a human readable netmask on Darwin" do
        sample_output_file = File.dirname(__FILE__) + "/../data/darwin_ifconfig_single_interface"

        darwin_ifconfig_interface = File.new(sample_output_file).read()

        Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(darwin_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interface_value("en1", "netmask").should == "255.255.255.0"
    end

    [:freebsd, :netbsd, :openbsd, :sunos, :darwin].each do |platform|
        it "should require conversion from hex on #{platform}" do
            Facter::Util::IP.convert_from_hex?(platform).should == true
        end
    end
end
