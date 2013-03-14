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
      expect(to_s).to eq 'Linux'
    end
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it "should be true" do
      expect(convert_netmask_from_hex?).to be false
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

      it { expect(bonding_master).to be_nil }
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
        expect(interfaces).to eq ["eth0", "lo"]
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
        expect(interfaces).to eq ["eth0", "lo"]
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

        it { expect(value_for_interface_and_label).to eq 'bar' }
      end
    end

    describe "normal interface" do
      let(:ifconfig_path) { '/usr/bin/ifconfig' }
      let(:exec_cmd) { "#{ifconfig_path} #{interface} 2> /dev/null" }

      let(:ifconfig_output) do
        my_fixture_read "ifconfig_single_interface_#{interface}"
      end

      before :each do
        described_class.expects(:ifconfig_path).returns(ifconfig_path)
        described_class.expects(:exec).with(exec_cmd).returns(ifconfig_output)
      end

      describe "eth0" do
        let(:interface) { 'eth0' }

        describe "mtu" do
          let(:label) { 'mtu' }

          it { expect(value_for_interface_and_label).to eq '1500' }
        end
      end

      describe "lo" do
        let(:interface) { 'lo' }

        describe "mtu" do
          let(:label) { 'mtu' }

          it { expect(value_for_interface_and_label).to eq '16436' }
        end
      end
    end

    describe "bonded interface" do
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

        it { expect(value_for_interface_and_label).to eq "00:11:22:33:44:55" }
      end
    end
  end
end
