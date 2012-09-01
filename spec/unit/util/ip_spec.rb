#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'facter/util/ip'

describe Facter::Util::IP do
  include FacterSpec::ConfigHelper

  before :each do
    given_a_configuration_of(:is_windows => false)
  end

  [:freebsd, :linux, :netbsd, :openbsd, :sunos, :darwin, :"hp-ux", :"gnu/kfreebsd", :windows].each do |platform|
    it "should be supported on #{platform}" do
      given_a_configuration_of(:is_windows => platform == :windows)
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
    Facter.stubs(:value).with(:kernel).returns(:linux)
    proc = my_fixture_read("linux_proc_with_single_interface")
    File.stubs(:read).with('/proc/net/dev').returns(proc)
    Facter::Util::IP.get_interfaces().should == ["eth0", "lo"]
  end

  it "should return a list two interfaces on Darwin with two interfaces" do
    Facter.stubs(:value).with(:kernel).returns(:darwin)
    interfaces = my_fixture_read("darwin_ifconfig-l")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -l').returns interfaces
    Facter::Util::IP.get_interfaces().should == ["lo0", "en0"]
  end

  it "should return a list two interfaces on Solaris with two interfaces multiply reporting" do
    Facter.stubs(:value).with(:kernel).returns(:sunos)
    solaris_ifconfig = my_fixture_read("solaris_ifconfig_all_with_multiple_interfaces")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(solaris_ifconfig)
    Facter::Util::IP.get_interfaces().should == ["lo0", "e1000g0"]
  end

  it "should return a list three interfaces on HP-UX with three interfaces multiply reporting" do
    Facter.stubs(:value).with(:kernel).returns(:"hp-ux")
    hpux_netstat = my_fixture_read("hpux_netstat_all_interfaces")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(hpux_netstat)
    Facter::Util::IP.get_interfaces().should == ["lan1", "lan0", "lo0"]
  end

  it "should return a list of six interfaces on a GNU/kFreeBSD with three interfaces" do
    Facter.stubs(:value).with(:kernel).returns(:"gnu/kfreebsd")
    interfaces = my_fixture_read("freebsd_ifconfig-l")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -l').returns interfaces
    Facter::Util::IP.get_interfaces().should == ["em0", "plip0", "lo0"]
  end

  it "should return a list of only connected interfaces on Windows" do
    Facter.fact(:kernel).stubs(:value).returns(:windows)
    windows_netsh = my_fixture_read("windows_netsh_all_interfaces")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(windows_netsh)
    Facter::Util::IP.get_interfaces().should == ["Loopback Pseudo-Interface 1", "Local Area Connection", "Teredo Tunneling Pseudo-Interface"]
  end

  it "should return a value for a specific interface" do
    Facter::Util::IP.should respond_to(:get_interface_value)
  end

  it "should not return interface information for unsupported platforms" do
    Facter.stubs(:value).with(:kernel).returns("bleah")
    Facter::Util::IP.netmask("e1000g0").should == []
  end

  describe "on solaris" do

    before :each do
      Facter.stubs(:value).with(:kernel).returns(:sunos)
      solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig e1000g0').returns(solaris_ifconfig_interface)
    end

    it "should return ipaddress information for a single interface" do
      Facter::Util::IP.ipaddress("e1000g0", "ipv4").should == "172.16.15.138"
    end

    it "should return netmask information for a single interface" do
      Facter::Util::IP.netmask("e1000g0").should == "255.255.255.0"
    end

    it "should return calculated network information for a single interface" do
      Facter::Util::IP.get_network_value("e1000g0").should == "172.16.15.0"
    end
  end

  it "should return ipaddress information for HP-UX" do
    hpux_ifconfig_interface = my_fixture_read("hpux_ifconfig_single_interface")

    FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(true)
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig lan0').returns(hpux_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns(:"hp-ux")

    Facter::Util::IP.ipaddress('lan0', 'ipv4').should == "168.24.80.71"
  end

  it "should return macaddress information for HP-UX" do
    hpux_lanscan_output = my_fixture_read("hpux_lanscan_single_output")

    FileTest.stubs(:exists?).with("/sbin/lanscan").returns(true)
    Facter::Util::Resolution.stubs(:exec).with('/sbin/lanscan -a 0').returns(hpux_lanscan_output)
    Facter.stubs(:value).with(:kernel).returns(:"hp-ux")

    Facter::Util::IP.macaddress("lan0").should == "00306e3899af"
  end

  it "should return macaddress with leading zeros stripped off for GNU/kFreeBSD" do
    kfreebsd_ifconfig = my_fixture_read("debian_kfreebsd_ifconfig")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig em0').returns(kfreebsd_ifconfig)
    Facter.stubs(:value).with(:kernel).returns("GNU/kFreeBSD")

    Facter::Util::IP.macaddress("em0").should == "0:11:a:59:67:90"
  end

  it "should return netmask information for HP-UX" do
    hpux_ifconfig_interface = my_fixture_read("hpux_ifconfig_single_interface")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig lan0').returns(hpux_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns(:"hp-ux")

    Facter::Util::IP.netmask("lan0").should == "255.255.255.0"
  end

  it "should return calculated network information for HP-UX" do
    hpux_ifconfig_interface = my_fixture_read("hpux_ifconfig_single_interface")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig lan0').returns(hpux_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("HP-UX")

    Facter::Util::IP.get_network_value("lan0").should == "168.24.80.0"
  end

  it "should return interface information for FreeBSD supported via an alias" do
    ifconfig_interface = my_fixture_read("6.0-STABLE_FreeBSD_ifconfig")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig fxp0').returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("FreeBSD")

    Facter::Util::IP.macaddress("fxp0").should == "00:0e:0c:68:67:7c"
  end

  it "should return macaddress information for OS X" do
    ifconfig_interface = my_fixture_read("osx_single_interface")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig en1').returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns(:darwin)

    Facter::Util::IP.macaddress("en1").should == "00:1b:63:ae:02:66"
  end

  it "should return all interfaces correctly on OS X" do
    Facter.stubs(:value).with(:kernel).returns(:darwin)
    interfaces = my_fixture_read("osx_ifconfig-l")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -l').returns interfaces

    Facter::Util::IP.get_interfaces().should == ["lo0", "gif0", "stf0", "en0", "fw0", "en1", "p2p0"]
  end

  it "should return a human readable netmask on Solaris" do
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter.stubs(:value).with(:kernel).returns(:sunos)
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig e1000g0').returns(solaris_ifconfig_interface)

    Facter::Util::IP.netmask("e1000g0").should == "255.255.255.0"
  end

  it "should return a human readable netmask on HP-UX" do
    hpux_ifconfig_interface = my_fixture_read("hpux_ifconfig_single_interface")

    Facter.stubs(:value).with(:kernel).returns(:"hp-ux")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig lan0').returns(hpux_ifconfig_interface)

    Facter::Util::IP.netmask("lan0").should == "255.255.255.0"
  end

  it "should return a human readable netmask on Darwin" do
    darwin_ifconfig_interface = my_fixture_read("darwin_ifconfig_single_interface")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig en1').returns(darwin_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns(:darwin)

    Facter::Util::IP.netmask("en1").should == "255.255.255.0"
  end

  it "should return a human readable netmask on GNU/kFreeBSD" do
    kfreebsd_ifconfig = my_fixture_read("debian_kfreebsd_ifconfig")

    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig em1').returns(kfreebsd_ifconfig)
    Facter.stubs(:value).with(:kernel).returns(:"gnu/kfreebsd")

    Facter::Util::IP.netmask("em1").should == "255.255.255.0"
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

  describe "the find_execs function" do

    describe "for ipaddress" do
      it "should return appropriate executables for /sbin/ifconfig on linux" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(true)
        FileTest.stubs(:exists?).with("/sbin/ip").returns(false)
        Facter::Util::IP.find_exec('ipaddress', 'ipv4').should == "/sbin/ifconfig"
      end

      it "should return appropriate executables for /sbin/ip on linux" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(false)
        FileTest.stubs(:exists?).with("/sbin/ip").returns(true)
        Facter::Util::IP.find_exec('ipaddress', 'ipv4').should == "/sbin/ip addr show"
      end

      it "should return appropriate executables for windows" do
        Facter.stubs(:value).with(:kernel).returns(:windows)
        FileTest.stubs(:exists?).with("/system32/netsh.exe").returns(true)
        Facter::Util::IP.find_exec('ipaddress', 'ipv4').should == "/system32/netsh.exe interface ip show interface"
      end

      [:freebsd, :netbsd, :openbsd, :sunos, :darwin, :"hp-ux", :"gnu/kfreebsd"].each do |platform|
        it "should return appropriate executables on #{platform}" do
          Facter.stubs(:value).with(:kernel).returns(platform)
          Facter::Util::IP.find_exec('ipaddress', 'ipv4').should == "/sbin/ifconfig"
        end
      end
    end

  end

  describe "the find_entry function" do
    describe "for ipaddress" do
      it "should return an appropriate token for ipconfig on linux for ipv4" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv4', "/sbin/ifconfig").should == 'inet addr: '
      end

      it "should return an appropriate token for ip on linux for ipv4" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv4', "/sbin/ip addr show").should == 'inet '
      end

      it "should return an appropriate token for ipconfig on linux for ipv6" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv6', "/sbin/ifconfig").should == 'inet6 addr: '
      end

      it "should return an appropriate token for ip on linux for ipv6" do
        Facter.stubs(:value).with(:kernel).returns("Linux")
        Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv6', "/sbin/ip addr show").should == 'inet6 '
      end

      [:sunos, :"hp-ux"].each do |platform|
        it "should return an appropriate token for ipconfig on #{platform} for ipv4" do
          Facter.stubs(:value).with(:kernel).returns(platform)
          Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv4', "/sbin/ifconfig").should == 'inet '
        end
      end
    end

    [:freebsd, :netbsd, :openbsd, :darwin, :"gnu/kfreebsd"].each do |platform|
      it "should return an appropriate token for ipconfig on #{platform} for ipv4" do
        Facter.stubs(:value).with(:kernel).returns(platform)
        Facter::Util::IP.find_entry('token', 'ipaddress', 'ipv4', "/sbin/ifconfig").should == 'inet addr: '
      end
    end

  end

  describe "on Windows" do
    before :each do
      Facter.stubs(:value).with(:kernel).returns(:windows)
      FileTest.stubs(:exists?).with("/system32/netsh.exe").returns(true)
    end

    it "should return ipaddress information" do
      windows_netsh = my_fixture_read("windows_netsh_single_interface")

      Facter::Util::Resolution.stubs(:exec).with('/system32/netsh.exe interface ip show interface Local Area Connection').returns(windows_netsh)
      Facter::Util::IP.ipaddress("Local Area Connection", "ipv4").should == "172.16.138.216"
    end

    it "should return a human readable netmask" do
      windows_netsh = my_fixture_read("windows_netsh_single_interface")

      Facter::Util::Resolution.stubs(:exec).with('/system32/netsh.exe interface ip show interface Local Area Connection').returns(windows_netsh)

      Facter::Util::IP.netmask("Local Area Connection").should == "255.255.255.0"
    end

    it "should return network information" do
      windows_netsh = my_fixture_read("windows_netsh_single_interface")

      Facter::Util::Resolution.stubs(:exec).with('/system32/netsh.exe interface ip show interface Local Area Connection').returns(windows_netsh)

      Facter::Util::IP.get_network_value("Local Area Connection").should == "172.16.138.0"
    end

    it "should return ipaddress6 information" do
      windows_netsh = my_fixture_read("windows_netsh_single_interface6")

      Facter::Util::Resolution.stubs(:exec).with('/system32/netsh.exe interface ipv6 show interface Teredo Tunneling Pseudo-Interface').returns(windows_netsh)
      Facter::Util::IP.ipaddress("Teredo Tunneling Pseudo-Interface", "ipv6").should == "2001:0:4137:9e76:2087:77a:53ef:7527"

    end

  end
end
