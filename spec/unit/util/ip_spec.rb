#! /usr/bin/env ruby

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
    linux_ifconfig = my_fixture_read("linux_ifconfig_all_with_single_interface")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(linux_ifconfig)
    Facter::Util::IP.get_interfaces().should == ["eth0", "lo"]
  end

  it "should return a list two interfaces on Darwin with two interfaces" do
    darwin_ifconfig = my_fixture_read("darwin_ifconfig_all_with_multiple_interfaces")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(darwin_ifconfig)
    Facter::Util::IP.get_interfaces().should == ["lo0", "en0"]
  end

  it "should return a list two interfaces on Solaris with two interfaces multiply reporting" do
    solaris_ifconfig = my_fixture_read("solaris_ifconfig_all_with_multiple_interfaces")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(solaris_ifconfig)
    Facter::Util::IP.get_interfaces().should == ["lo0", "e1000g0"]
  end

  it "should return a list of six interfaces on a GNU/kFreeBSD with six interfaces" do
    kfreebsd_ifconfig = my_fixture_read("debian_kfreebsd_ifconfig")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(kfreebsd_ifconfig)
    Facter::Util::IP.get_interfaces().should == ["em0", "em1", "bge0", "bge1", "lo0", "vlan0"]
  end

  it "should return a list of only connected interfaces on Windows" do
    Facter.fact(:kernel).stubs(:value).returns("windows")

    Facter::Util::IP::Windows.expects(:interfaces).returns(["Loopback Pseudo-Interface 1", "Local Area Connection", "Teredo Tunneling Pseudo-Interface"])
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
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("SunOS")

    Facter::Util::IP.get_interface_value("e1000g0", "ipaddress").should == "172.16.15.138"
  end

  it "should return netmask information for Solaris" do
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("SunOS")

    Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
  end

  it "should return calculated network information for Solaris" do
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter::Util::IP.stubs(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("SunOS")

    Facter::Util::IP.get_network_value("e1000g0").should == "172.16.15.0"
  end

  it "should return macaddress with leading zeros stripped off for GNU/kFreeBSD" do
    kfreebsd_ifconfig = my_fixture_read("debian_kfreebsd_ifconfig")

    Facter::Util::IP.expects(:get_single_interface_output).with("em0").returns(kfreebsd_ifconfig)
    Facter.stubs(:value).with(:kernel).returns("GNU/kFreeBSD")

    Facter::Util::IP.get_interface_value("em0", "macaddress").should == "0:11:a:59:67:90"
  end

  it "should return interface information for FreeBSD supported via an alias" do
    ifconfig_interface = my_fixture_read("6.0-STABLE_FreeBSD_ifconfig")

    Facter::Util::IP.expects(:get_single_interface_output).with("fxp0").returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("FreeBSD")

    Facter::Util::IP.get_interface_value("fxp0", "macaddress").should == "00:0e:0c:68:67:7c"
  end

  it "should return macaddress information for OS X" do
    ifconfig_interface = my_fixture_read("Mac_OS_X_10.5.5_ifconfig")

    Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Darwin")

    Facter::Util::IP.get_interface_value("en1", "macaddress").should == "00:1b:63:ae:02:66"
  end

  it "should return all interfaces correctly on OS X" do
    ifconfig_interface = my_fixture_read("Mac_OS_X_10.5.5_ifconfig")

    Facter::Util::IP.expects(:get_all_interface_output).returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Darwin")

    Facter::Util::IP.get_interfaces().should == ["lo0", "gif0", "stf0", "en0", "fw0", "en1", "vmnet8", "vmnet1"]
  end

  it "should return a human readable netmask on Solaris" do
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("SunOS")

    Facter::Util::IP.get_interface_value("e1000g0", "netmask").should == "255.255.255.0"
  end

  it "should return a human readable netmask on Darwin" do
    darwin_ifconfig_interface = my_fixture_read("darwin_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(darwin_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Darwin")

    Facter::Util::IP.get_interface_value("en1", "netmask").should == "255.255.255.0"
  end

  it "should return a human readable netmask on GNU/kFreeBSD" do
    kfreebsd_ifconfig = my_fixture_read("debian_kfreebsd_ifconfig")

    Facter::Util::IP.expects(:get_single_interface_output).with("em1").returns(kfreebsd_ifconfig)
    Facter.stubs(:value).with(:kernel).returns("GNU/kFreeBSD")

    Facter::Util::IP.get_interface_value("em1", "netmask").should == "255.255.255.0"
  end

  it "should return correct macaddress information for infiniband on Linux" do
    correct_ifconfig_interface = my_fixture_read("linux_get_single_interface_ib0")

    Facter::Util::IP.expects(:get_single_interface_output).with("ib0").returns(correct_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Linux")

    Facter::Util::IP.get_interface_value("ib0", "macaddress").should == "80:00:00:4a:fe:80:00:00:00:00:00:00:00:02:c9:03:00:43:27:21"
  end

  it "should replace the incorrect macaddress with the correct macaddress in ifconfig for infiniband on Linux" do
    ifconfig_interface = my_fixture_read("linux_ifconfig_ib0")
    correct_ifconfig_interface = my_fixture_read("linux_get_single_interface_ib0")

    Facter::Util::IP.expects(:get_infiniband_macaddress).with("ib0").returns("80:00:00:4a:fe:80:00:00:00:00:00:00:00:02:c9:03:00:43:27:21")
    Facter::Util::IP.expects(:ifconfig_interface).with("ib0").returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Linux")

    Facter::Util::IP.get_single_interface_output("ib0").should == correct_ifconfig_interface
  end

  it "should return fake macaddress information for infiniband on Linux when neither sysfs or /sbin/ip are available" do
    ifconfig_interface = my_fixture_read("linux_ifconfig_ib0")

    File.expects(:exists?).with("/sys/class/net/ib0/address").returns(false)
    File.expects(:exists?).with("/sbin/ip").returns(false)
    Facter::Util::IP.expects(:ifconfig_interface).with("ib0").returns(ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Linux")

    Facter::Util::IP.get_interface_value("ib0", "macaddress").should == "FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF"
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

  it "should return mtu information on Linux" do
    linux_ifconfig = my_fixture_read("linux_ifconfig_all_with_single_interface")
    Facter::Util::IP.stubs(:get_all_interface_output).returns(linux_ifconfig)
    Facter::Util::IP.stubs(:get_single_interface_output).with("eth0").
      returns(my_fixture_read("linux_get_single_interface_eth0"))
    Facter::Util::IP.stubs(:get_single_interface_output).with("lo").
      returns(my_fixture_read("linux_get_single_interface_lo"))
    Facter.stubs(:value).with(:kernel).returns("Linux")

    Facter::Util::IP.get_interface_value("eth0", "mtu").should == "1500"
    Facter::Util::IP.get_interface_value("lo", "mtu").should == "16436"
  end

  it "should return mtu information on Darwin" do
    darwin_ifconfig_interface = my_fixture_read("darwin_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("en1").returns(darwin_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("Darwin")

    Facter::Util::IP.get_interface_value("en1", "mtu").should == "1500"
  end

  it "should return mtu information for Solaris" do
    solaris_ifconfig_interface = my_fixture_read("solaris_ifconfig_single_interface")

    Facter::Util::IP.expects(:get_single_interface_output).with("e1000g0").returns(solaris_ifconfig_interface)
    Facter.stubs(:value).with(:kernel).returns("SunOS")

    Facter::Util::IP.get_interface_value("e1000g0", "mtu").should == "1500"
  end

  # (#17487) - tests for HP-UX.
  # some fake data for testing robustness of regexps.
  def self.fake_netstat_in_examples
    examples = []
    examples << ["Header row\na line with none in it\na line without\nanother line without\n",
                 "a line without\nanother line without\n"]
    examples << ["Header row\na line without\na line with none in it\nanother line with none\nanother line without\n",
                 "a line without\nanother line without\n"]
    examples << ["Header row\na line with * asterisks *\na line with none in it\nanother line without\n",
                 "a line with  asterisks \nanother line without\n"]
    examples << ["a line with none none none in it\na line with none in it\na line without\nanother line without\n",
                 "another line without\n"]
    examples
  end

  fake_netstat_in_examples.each_with_index do |example, i|
    input, expected_output = example
    it "should pass regexp test on fake netstat input example #{i}" do
      Facter.stubs(:value).with(:kernel).returns("HP-UX")
      Facter::Util::IP.stubs(:hpux_netstat_in).returns(input)
      Facter::Util::IP.get_all_interface_output().should == expected_output
    end
  end

  # and some real data for exhaustive tests.
  def self.hpux_examples
    examples = []
    examples << ["HP-UX 11.11",
                   ["lan1",              "lan0",              "lo0"      ],
                   ["1500",              "1500",              "4136"     ],
                   ["10.1.1.6",          "192.168.3.10",      "127.0.0.1"],
                   ["255.255.255.0",     "255.255.255.0",     "255.0.0.0"],
                   ["00:10:79:7B:5C:DE", "00:30:7F:0C:79:DC", nil        ],
                   [my_fixture_read("hpux_1111_ifconfig_lan1"),
                      my_fixture_read("hpux_1111_ifconfig_lan0"),
                        my_fixture_read("hpux_1111_ifconfig_lo0")],
                           my_fixture_read("hpux_1111_netstat_in"),
                           my_fixture_read("hpux_1111_lanscan")]

    examples << ["HP-UX 11.31",
                   ["lan1",              "lan0",              "lo0"      ],
                   ["1500",              "1500",              "4136"     ],
                   ["10.1.54.36",        "192.168.30.152",    "127.0.0.1"],
                   ["255.255.255.0",     "255.255.255.0",     "255.0.0.0"],
                   ["00:17:FD:2D:2A:57", "00:12:31:7D:62:09", nil        ],
                   [my_fixture_read("hpux_1131_ifconfig_lan1"),
                      my_fixture_read("hpux_1131_ifconfig_lan0"),
                        my_fixture_read("hpux_1131_ifconfig_lo0")],
                           my_fixture_read("hpux_1131_netstat_in"),
                           my_fixture_read("hpux_1131_lanscan")]

    examples << ["HP-UX 11.31 with an asterisk after a NIC that has an address",
                   ["lan1",              "lan0",              "lo0"      ],
                   ["1500",              "1500",              "4136"     ],
                   ["10.10.0.5",         "192.168.3.9",       "127.0.0.1"],
                   ["255.255.255.0",     "255.255.255.0",     "255.0.0.0"],
                   ["00:10:79:7B:BE:46", "00:30:5D:06:26:B2", nil        ],
                   [my_fixture_read("hpux_1131_asterisk_ifconfig_lan1"),
                      my_fixture_read("hpux_1131_asterisk_ifconfig_lan0"),
                        my_fixture_read("hpux_1131_asterisk_ifconfig_lo0")],
                           my_fixture_read("hpux_1131_asterisk_netstat_in"),
                           my_fixture_read("hpux_1131_asterisk_lanscan")]

    examples << ["HP-UX 11.31 with NIC bonding and one virtual NIC",
                   ["lan4:1",        "lan1",              "lo0",       "lan4"             ],
                   ["1500",          "1500",              "4136",      "1500"             ],
                   ["192.168.1.197", "192.168.30.32",     "127.0.0.1", "192.168.32.75"    ],
                   ["255.255.255.0", "255.255.255.0",     "255.0.0.0", "255.255.255.0"    ],
                   [nil,             "00:12:81:9E:48:DE", nil,         "00:12:81:9E:4A:7E"],
                   [my_fixture_read("hpux_1131_nic_bonding_ifconfig_lan4_1"),
                      my_fixture_read("hpux_1131_nic_bonding_ifconfig_lan1"),
                        my_fixture_read("hpux_1131_nic_bonding_ifconfig_lo0"),
                          my_fixture_read("hpux_1131_nic_bonding_ifconfig_lan4")],
                           my_fixture_read("hpux_1131_nic_bonding_netstat_in"),
                           my_fixture_read("hpux_1131_nic_bonding_lanscan")]
    examples
  end

  hpux_examples.each do |example|
    description, array_of_expected_ifs, array_of_expected_mtus,
      array_of_expected_ips, array_of_expected_netmasks,
        array_of_expected_macs, array_of_ifconfig_fixtures,
           netstat_in_fixture, lanscan_fixture = example

    it "should return a list three interfaces on #{description}" do
      Facter.stubs(:value).with(:kernel).returns("HP-UX")
      Facter::Util::IP.stubs(:hpux_netstat_in).returns(netstat_in_fixture)
      Facter::Util::IP.get_interfaces().should == array_of_expected_ifs
    end

    array_of_expected_ifs.each_with_index do |nic, i|
      ifconfig_fixture = array_of_ifconfig_fixtures[i]
      expected_mtu = array_of_expected_mtus[i]
      expected_ip = array_of_expected_ips[i]
      expected_netmask = array_of_expected_netmasks[i]
      expected_mac = array_of_expected_macs[i]

      # (#17808) These tests fail because MTU facts haven't been implemented for HP-UX.
      #it "should return MTU #{expected_mtu} on #{nic} for #{description} example" do
      #  Facter.stubs(:value).with(:kernel).returns("HP-UX")
      #  Facter::Util::IP.stubs(:hpux_netstat_in).returns(netstat_in_fixture)
      #  Facter::Util::IP.stubs(:hpux_lanscan).returns(lanscan_fixture)
      #  Facter::Util::IP.stubs(:hpux_ifconfig_interface).with(nic).returns(ifconfig_fixture)
      #  Facter::Util::IP.get_interface_value(nic, "mtu").should == expected_mtu
      #end

      it "should return IP #{expected_ip} on #{nic} for #{description} example" do
        Facter.stubs(:value).with(:kernel).returns("HP-UX")
        Facter::Util::IP.stubs(:hpux_lanscan).returns(lanscan_fixture)
        Facter::Util::IP.stubs(:hpux_ifconfig_interface).with(nic).returns(ifconfig_fixture)
        Facter::Util::IP.get_interface_value(nic, "ipaddress").should == expected_ip
      end

      it "should return netmask #{expected_netmask} on #{nic} for #{description} example" do
        Facter.stubs(:value).with(:kernel).returns("HP-UX")
        Facter::Util::IP.stubs(:hpux_lanscan).returns(lanscan_fixture)
        Facter::Util::IP.stubs(:hpux_ifconfig_interface).with(nic).returns(ifconfig_fixture)
        Facter::Util::IP.get_interface_value(nic, "netmask").should == expected_netmask
      end

      it "should return MAC address #{expected_mac} on #{nic} for #{description} example" do
        Facter.stubs(:value).with(:kernel).returns("HP-UX")
        Facter::Util::IP.stubs(:hpux_lanscan).returns(lanscan_fixture)
        Facter::Util::IP.stubs(:hpux_ifconfig_interface).with(nic).returns(ifconfig_fixture)
        Facter::Util::IP.get_interface_value(nic, "macaddress").should == expected_mac
      end
    end
  end

  describe "on Windows" do
    require 'facter/util/ip/windows'

    before :each do
      Facter.stubs(:value).with(:kernel).returns("windows")
    end

    it "should return ipaddress information" do
      Facter::Util::IP::Windows.expects(:value_for_interface_and_label).with("Local Area Connection", "ipaddress").returns('172.16.138.216')

      Facter::Util::IP.get_interface_value("Local Area Connection", "ipaddress").should == "172.16.138.216"
    end

    it "should return network information" do
      Facter::Util::IP::Windows.expects(:value_for_interface_and_label).with("Local Area Connection", "ipaddress").returns('172.16.138.216')
      Facter::Util::IP::Windows.expects(:value_for_interface_and_label).with("Local Area Connection", "netmask").returns('255.255.255.0')

      Facter::Util::IP.get_network_value("Local Area Connection").should == "172.16.138.0"
    end

    it "should return ipaddress6 information" do
      Facter::Util::IP::Windows.expects(:value_for_interface_and_label).with("Local Area Connection", "ipaddress6").returns("2001:0:4137:9e76:2087:77a:53ef:7527")

      Facter::Util::IP.get_interface_value("Local Area Connection", "ipaddress6").should == "2001:0:4137:9e76:2087:77a:53ef:7527"
    end
  end

  describe "exec_ifconfig" do
    it "uses get_ifconfig" do
      Facter::Core::Execution.stubs(:exec)

      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig").once

      Facter::Util::IP.exec_ifconfig
    end

    it "support additional arguments" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Core::Execution.stubs(:exec).with("/sbin/ifconfig -a")

      Facter::Util::IP.exec_ifconfig(["-a"])
    end

    it "joins multiple arguments correctly" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Core::Execution.stubs(:exec).with("/sbin/ifconfig -a -e -i -j")

      Facter::Util::IP.exec_ifconfig(["-a","-e","-i","-j"])
    end
  end
  describe "get_ifconfig" do
    it "assigns /sbin/ifconfig if it is executable" do
      File.stubs(:executable?).returns(false)
      File.stubs(:executable?).with("/sbin/ifconfig").returns(true)
      Facter::Util::IP.get_ifconfig.should eq("/sbin/ifconfig")
    end
    it "assigns /usr/sbin/ifconfig if it is executable" do
      File.stubs(:executable?).returns(false)
      File.stubs(:executable?).with("/usr/sbin/ifconfig").returns(true)
      Facter::Util::IP.get_ifconfig.should eq("/usr/sbin/ifconfig")
    end
    it "assigns /bin/ifconfig if it is executable" do
      File.stubs(:executable?).returns(false)
      File.stubs(:executable?).with("/bin/ifconfig").returns(true)
      Facter::Util::IP.get_ifconfig.should eq("/bin/ifconfig")
    end
  end

  context "with bonded ethernet interfaces on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    describe "Facter::Util::Ip.get_interface_value" do
      before :each do
        Facter::Util::IP.stubs(:read_proc_net_bonding).
          with("/proc/net/bonding/bond0").
          returns(my_fixture_read("linux_2_6_35_proc_net_bonding_bond0"))

        Facter::Util::IP.stubs(:get_bonding_master).returns("bond0")
      end

      it 'provides the real device macaddress for eth0' do
        Facter::Util::IP.get_interface_value("eth0", "macaddress").should == "00:11:22:33:44:55"
      end
      it 'provides the real device macaddress for eth1' do
        Facter::Util::IP.get_interface_value("eth1", "macaddress").should == "00:11:22:33:44:56"
      end
    end
  end
end
