# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/linux'

describe Facter::Util::IP::Linux do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
  end

  describe ".to_s" do
    let :to_s do
      described_class.to_s
    end

    it "should be 'Linux'" do
      to_s.should eq 'Linux'
    end
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it "should be true" do
      convert_netmask_from_hex?.should be false
    end
  end

  describe ".bonding_master(interface)" do
    let :bonding_master do
      described_class.bonding_master(interface)
    end

    describe "on interface aliases" do
      let :interface do
        "eth0:1"
      end

      it { bonding_master.should be_nil }
    end
  end

  describe ".interfaces" do
    let :interfaces do
      described_class.interfaces
    end

    describe "without sysfs" do
      let :ifconfig_output do
        my_fixture_read("ifconfig_all_with_single_interface")
      end

      before :each do
        File.expects(:exist?).with('/sys/class/net').returns(false)
        described_class.expects(:ifconfig_path).returns('/usr/bin/ifconfig')
        described_class.expects(:exec).with(anything).returns(ifconfig_output)
      end

      it "should return an array with a single interface and the loopback" do
        interfaces.should eq ["eth0", "lo"]
      end
    end

    describe "with sysfs" do
      let :sysfs do
        %w[/sys/class/net/eth0 /sys/class/net/lo]
      end

      before :each do
        File.expects(:exist?).with('/sys/class/net').returns(true)
        Dir.expects(:glob).with('/sys/class/net/*').returns(sysfs)
      end

      it "should return an array with a single interface and the loopback" do
        interfaces.should eq ["eth0", "lo"]
      end
    end
  end

  describe "value_for_interface_and_label(interface, label)" do
    let :value_for_interface_and_label do
      described_class.value_for_interface_and_label interface, label
    end

    describe "infiniband interface" do
      let(:interface) { 'ib0' }

      let :ifconfig_output do
        my_fixture_read "ifconfig_with_single_interface_ib0"
      end

      describe "macaddress" do
        let(:label) { 'macaddress' }

        before :each do
          described_class.expects(:infiniband_macaddress).returns('bar')
        end

        it { value_for_interface_and_label.should eq 'bar' }
      end
    end

    def executes_ifconfig_for(interface, result)
      described_class.expects(:exec).with(regexp_matches(/#{interface}/)).returns(result)
    end

    describe "on Ubuntu (net-tools 1.60)" do
      describe "eth0" do
        before :each do
          executes_ifconfig_for("eth0", my_fixture_read("ifconfig_single_interface_eth0"))
        end

        it "extracts the mtu" do
          described_class.value_for_interface_and_label("eth0", "mtu").should eq "1500"
        end

        it "extracts the netmask" do
          described_class.value_for_interface_and_label("eth0", "netmask").should eq "255.255.255.0"
        end
      end

      describe "lo" do
        before :each do
          executes_ifconfig_for("lo", my_fixture_read("ifconfig_single_interface_lo"))
        end

        it "extracts the mtu" do
          described_class.value_for_interface_and_label("lo", "mtu").should eq "16436"
        end

        it "extracts the netmask" do
          described_class.value_for_interface_and_label("lo", "netmask").should eq "255.0.0.0"
        end
      end
    end

    describe "on Archlinux (net-tools 1.60)" do
      describe "em1" do
        before :each do
          executes_ifconfig_for("em1", my_fixture_read("ifconfig_net_tools_1.60.txt.em1"))
        end

        it "extracts the mtu" do
          pending "Resolution of Archlinux, which outputs BSD style output, getting parsed using Linux formatting" do
            described_class.value_for_interface_and_label("em1", "mtu").should eq "1500"
          end
        end

        it "extracts the netmask" do
          described_class.value_for_interface_and_label("em1", "netmask").should eq "255.255.255.0"
        end
      end

      describe "lo" do
        before :each do
          executes_ifconfig_for("lo", my_fixture_read("ifconfig_net_tools_1.60.txt.lo"))
        end

        it "extracts the mtu" do
          pending "Resolution of Archlinux, which outputs BSD style output, getting parsed using Linux formatting" do
            described_class.value_for_interface_and_label("lo", "mtu").should eq "16436"
          end
        end

        it "extracts the netmask" do
          described_class.value_for_interface_and_label("lo", "netmask").should eq "255.0.0.0"
        end
      end
    end

    describe "bonded interface on Linux kernel 2.6.35" do
      let(:interface) { 'eth0' }
      let(:bond) { 'bond0' }
      let(:proc_net_path) { '/proc/net/bonding/bond0' }

      before :each do
        proc_net = my_fixture_read "2_6_35_proc_net_bonding_#{bond}"
        described_class.expects(:bonding_master).with(interface).returns(bond)
        File.expects(:exists?).with(proc_net_path).returns(true)
        File.expects(:read).with(proc_net_path).returns(proc_net)
      end

      describe "macaddress" do
        let(:label) { 'macaddress' }

        it { value_for_interface_and_label.should eq "00:11:22:33:44:55" }
      end
    end
  end
end
