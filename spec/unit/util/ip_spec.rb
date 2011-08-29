#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/ip'

describe Facter::Util::IP do
    before :each do
        Facter::Util::Config.stubs(:is_windows?).returns(false)
    end

    [:freebsd, :linux, :netbsd, :openbsd, :sunos, :darwin, :"hp-ux", :"gnu/kfreebsd", :windows].each do |platform|
        it "should be supported on #{platform}" do
            Facter::Util::Config.stubs(:is_windows?).returns(platform == :windows)
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

    it "should return a list with a single interface and the loopback interface on Linux with a single interface" do
        sample_output_file = File.dirname(__FILE__) + '/../data/linux_ifconfig_all_with_single_interface'
        linux_ifconfig = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(linux_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["eth0", "lo"]
    end

    it "should return a list two interfaces on Darwin with two interfaces" do
        sample_output_file = File.dirname(__FILE__) + '/../data/darwin_ifconfig_all_with_multiple_interfaces'
        darwin_ifconfig = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(darwin_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["lo0", "en0"]
    end

    it "should return a list two interfaces on Solaris with two interfaces multiply reporting" do
        sample_output_file = File.dirname(__FILE__) + '/../data/solaris_ifconfig_all_with_multiple_interfaces'
        solaris_ifconfig = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(solaris_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["lo0", "e1000g0"]
    end

    it "should return a list three interfaces on HP-UX with three interfaces multiply reporting" do
        sample_output_file = File.dirname(__FILE__) + '/../data/hpux_netstat_all_interfaces'
        hpux_netstat = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(hpux_netstat)
        Facter::Util::IP.get_interfaces().should == ["lan1", "lan0", "lo0"]
    end

    it "should return a list of six interfaces on a GNU/kFreeBSD with six interfaces" do
        sample_output_file = File.dirname(__FILE__) + '/../data/debian_kfreebsd_ifconfig'
        kfreebsd_ifconfig = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(kfreebsd_ifconfig)
        Facter::Util::IP.get_interfaces().should == ["em0", "em1", "bge0", "bge1", "lo0", "vlan0"]
    end

    it "should return a list of only connected interfaces on Windows" do
        Facter.fact(:kernel).stubs(:value).returns("windows")
        sample_output_file = File.dirname(__FILE__) + '/../data/windows_netsh_all_interfaces'
        windows_netsh = File.read(sample_output_file)
        Facter::Util::IP.stubs(:get_all_interface_output).returns(windows_netsh)
        Facter::Util::IP.get_interfaces().should == ["Loopback Pseudo-Interface 1", "Local Area Connection", "Teredo Tunneling Pseudo-Interface"]
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
        solaris_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "ipaddress").should == "172.16.15.138"
    end

    it "should return netmask information for Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
    end

    it "should return calculated network information for Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.stubs(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_network_value("e1000g0").should == "172.16.15.0"
    end

    it "should return ipaddress information for HP-UX" do
        sample_output_file = File.dirname(__FILE__) + "/../data/hpux_ifconfig_single_interface"
        hpux_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("lan0").returns(hpux_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("HP-UX")

        Facter::Util::IP.get_interface_value("lan0", "ipaddress").should == "168.24.80.71"
    end

    it "should return macaddress information for HP-UX" do
        sample_output_file = File.dirname(__FILE__) + "/../data/hpux_ifconfig_single_interface"
        hpux_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("lan0").returns(hpux_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("HP-UX")

        Facter::Util::IP.get_interface_value("lan0", "macaddress").should == "00:13:21:BD:9C:B7"
    end

    it "should return macaddress with leading zeros stripped off for GNU/kFreeBSD" do
        sample_output_file = File.dirname(__FILE__) + "/../data/debian_kfreebsd_ifconfig"
        kfreebsd_ifconfig = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("em0").returns(kfreebsd_ifconfig)
        Facter.stubs(:value).with(:kernel).returns("GNU/kFreeBSD")

        Facter::Util::IP.get_interface_value("em0", "macaddress").should == "0:11:a:59:67:90"
    end

    it "should return netmask information for HP-UX" do
        sample_output_file = File.dirname(__FILE__) + "/../data/hpux_ifconfig_single_interface"
        hpux_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("lan0").returns(hpux_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("HP-UX")

        Facter::Util::IP.get_interface_value("lan0", "netmask").should == "255.255.255.0"
    end

    it "should return calculated network information for HP-UX" do
        sample_output_file = File.dirname(__FILE__) + "/../data/hpux_ifconfig_single_interface"
        hpux_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.stubs(:get_single_interface_output).with("lan0").returns(hpux_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("HP-UX")

        Facter::Util::IP.get_network_value("lan0").should == "168.24.80.0"
    end

    it "should return interface information for FreeBSD supported via an alias" do
        sample_output_file = File.dirname(__FILE__) + "/../data/6.0-STABLE_FreeBSD_ifconfig"
        ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("fxp0").returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("FreeBSD")

        Facter::Util::IP.get_interface_value("fxp0", "macaddress").should == "00:0e:0c:68:67:7c"
    end

    it "should return macaddress information for OS X" do
        sample_output_file = File.dirname(__FILE__) + "/../data/Mac_OS_X_10.5.5_ifconfig"
        ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interface_value("en1", "macaddress").should == "00:1b:63:ae:02:66"
    end

    it "should return all interfaces correctly on OS X" do
        sample_output_file = File.dirname(__FILE__) + "/../data/Mac_OS_X_10.5.5_ifconfig"
        ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_all_interface_output).returns(ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interfaces().should == ["lo0", "gif0", "stf0", "en0", "fw0", "en1", "vmnet8", "vmnet1"]
    end

    it "should return a human readable netmask on Solaris" do
        sample_output_file = File.dirname(__FILE__) + "/../data/solaris_ifconfig_single_interface"
        solaris_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("SunOS")

        Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
    end

    it "should return a human readable netmask on HP-UX" do
        sample_output_file = File.dirname(__FILE__) + "/../data/hpux_ifconfig_single_interface"
        hpux_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("lan0").returns(hpux_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("HP-UX")

        Facter::Util::IP.get_interface_value("lan0", "netmask").should == "255.255.255.0"
    end

    it "should return a human readable netmask on Darwin" do
        sample_output_file = File.dirname(__FILE__) + "/../data/darwin_ifconfig_single_interface"

        darwin_ifconfig_interface = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(darwin_ifconfig_interface)
        Facter.stubs(:value).with(:kernel).returns("Darwin")

        Facter::Util::IP.get_interface_value("en1", "netmask").should == "255.255.255.0"
    end

    it "should return a human readable netmask on GNU/kFreeBSD" do
        sample_output_file = File.dirname(__FILE__) + "/../data/debian_kfreebsd_ifconfig"

        kfreebsd_ifconfig = File.read(sample_output_file)

        Facter::Util::IP.expects(:get_single_interface_output).with("em1").returns(kfreebsd_ifconfig)
        Facter.stubs(:value).with(:kernel).returns("GNU/kFreeBSD")

        Facter::Util::IP.get_interface_value("em1", "netmask").should == "255.255.255.0"
    end

    it "should not get bonding master on interface aliases" do
        Facter.stubs(:value).with(:kernel).returns("Linux")

        Facter::Util::IP.get_bonding_master("eth0:1").should be_nil
    end

    [:freebsd, :netbsd, :openbsd, :sunos, :darwin, :"hp-ux"].each do |platform|
        it "should require conversion from hex on #{platform}" do
            Facter::Util::IP.convert_from_hex?(platform).should == true
        end
    end

    [:windows].each do |platform|
        it "should not require conversion from hex on #{platform}" do
            Facter::Util::IP.convert_from_hex?(platform).should be_false
        end
    end

    it "should return an arp address on Linux" do
        Facter.stubs(:value).with(:kernel).returns("Linux")

        Facter::Util::IP.expects(:get_arp_value).with("eth0").returns("00:00:0c:9f:f0:04")
        Facter::Util::IP.get_arp_value("eth0").should == "00:00:0c:9f:f0:04"
    end

    describe "on Windows" do
        before :each do
            Facter.stubs(:value).with(:kernel).returns("windows")
        end

        it "should return ipaddress information" do
            sample_output_file = File.dirname(__FILE__) + "/../data/windows_netsh_single_interface"
            windows_netsh = File.read(sample_output_file)

            Facter::Util::IP.expects(:get_output_for_interface_and_label).with("Local Area Connection", "ipaddress").returns(windows_netsh)

            Facter::Util::IP.get_interface_value("Local Area Connection", "ipaddress").should == "172.16.138.216"
        end

        it "should return a human readable netmask" do
            sample_output_file = File.dirname(__FILE__) + "/../data/windows_netsh_single_interface"
            windows_netsh = File.read(sample_output_file)

            Facter::Util::IP.expects(:get_output_for_interface_and_label).with("Local Area Connection", "netmask").returns(windows_netsh)

            Facter::Util::IP.get_interface_value("Local Area Connection", "netmask").should == "255.255.255.0"
        end

        it "should return network information" do
            sample_output_file = File.dirname(__FILE__) + "/../data/windows_netsh_single_interface"
            windows_netsh = File.read(sample_output_file)

            Facter::Util::IP.stubs(:get_output_for_interface_and_label).with("Local Area Connection", "ipaddress").returns(windows_netsh)
            Facter::Util::IP.stubs(:get_output_for_interface_and_label).with("Local Area Connection", "netmask").returns(windows_netsh)

            Facter::Util::IP.get_network_value("Local Area Connection").should == "172.16.138.0"
        end

        it "should return ipaddress6 information" do
            sample_output_file = File.dirname(__FILE__) + "/../data/windows_netsh_single_interface6"
            windows_netsh = File.read(sample_output_file)

            Facter::Util::IP.expects(:get_output_for_interface_and_label).with("Teredo Tunneling Pseudo-Interface", "ipaddress6").returns(windows_netsh)

            Facter::Util::IP.get_interface_value("Teredo Tunneling Pseudo-Interface", "ipaddress6").should == "2001:0:4137:9e76:2087:77a:53ef:7527"
        end
    end
end
