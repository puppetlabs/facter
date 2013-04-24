# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/gnu_k_free_bsd'

describe Facter::Util::IP::GNUkFreeBSD do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns('GNU/kFreeBSD')
  end

  describe ".to_s" do
    let :to_s do
      described_class.to_s
    end

    it "should be 'GNU/kFreeBSD'" do
      expect(to_s).to eq 'GNU/kFreeBSD'
    end
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it "should be true" do
      expect(convert_netmask_from_hex?).to be true
    end
  end

  describe ".bonding_master" do
    let :bonding_master do
      described_class.bonding_master('eth0')
    end

    it { expect(bonding_master).to be_nil }
  end

  describe ".interfaces" do
    let :interfaces do
      described_class.interfaces
    end

    let :ifconfig_output do
      my_fixture_read("ifconfig_all_with_multiple_interfaces")
    end

    before :each do
      described_class.expects(:ifconfig_path).returns('/usr/bin/ifconfig')
      described_class.expects(:exec).with(anything).returns(ifconfig_output)
    end

    it "should return an array with six interfaces" do
      expect(interfaces).to eq %w[em0 em1 bge0 bge1 lo0 vlan0]
    end
  end

  describe ".value_for_interface_and_label(interface, label)" do
    let :value_for_interface_and_label do
      described_class.value_for_interface_and_label interface, label
    end

    let(:interface) { 'em1' }
    let(:ifconfig_output) { my_fixture_read "ifconfig_with_single_interface" }
    let(:ifconfig_path) { "/usr/bin/ifconfig" }
    let(:exec_cmd) { "#{ifconfig_path} #{interface} 2> /dev/null" }

    before :each do
      described_class.expects(:ifconfig_path).returns(ifconfig_path)
      described_class.expects(:exec).with(exec_cmd).returns(ifconfig_output)
    end

    describe "macaddress" do
      let(:label) { 'macaddress' }

      it { expect(value_for_interface_and_label).to eq '0:11:a:59:67:91' }
    end

    describe "netmask" do
      let(:label) { 'netmask' }

      it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
    end
  end
end
