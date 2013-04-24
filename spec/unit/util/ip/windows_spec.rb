# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/windows'

describe Facter::Util::IP::Windows do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns('windows')
  end

  describe ".to_s" do
    let(:to_s) { described_class.to_s }

    it { expect(to_s).to eq 'windows' }
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it { expect(convert_netmask_from_hex?).to be false }
  end

  describe ".bonding_master" do
    let(:bonding_master) { described_class.bonding_master('eth0') }

    it { expect(bonding_master).to be_nil }
  end

  describe ".interfaces" do
    let(:interfaces) { described_class.interfaces }

    let(:netsh_output) { my_fixture_read "netsh_all_interfaces" }

    let :expected_interfaces do
      [
        "Loopback Pseudo-Interface 1",
        "Local Area Connection",
        "Teredo Tunneling Pseudo-Interface"
      ]
    end

    before :each do
      described_class.expects(:exec).with(anything).returns(netsh_output)
    end

    it "should return an array of only connected interfaces" do
      expect(interfaces).to eq expected_interfaces
    end
  end

  describe "value_for_interface_and_label(interface, label)" do
    let(:interface) { 'Local Area Connection' }
    let(:netsh_output) { my_fixture_read("netsh_with_single_interface") }

    let :value_for_interface_and_label do
      described_class.value_for_interface_and_label interface, label
    end

    let(:exec_cmd) do
      "#{described_class::NETSH} interface ip show address \"#{interface}\""
    end

    before :each do
      described_class.expects(:exec).with(exec_cmd).returns(netsh_output)
    end

    describe "ipaddress" do
      let(:label) { 'ipaddress' }

      it { expect(value_for_interface_and_label).to eq '172.16.138.216' }
    end

    describe "netmask" do
      let(:label) { 'netmask' }

      it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
    end

    describe "ipaddress6" do
      let(:interface) { 'Teredo Tunneling Pseudo-Interface' }
      let(:label) { 'ipaddress6' }
      let(:expected_ip) { '2001:0:4137:9e76:2087:77a:53ef:7527' }
      let(:netsh_output) { my_fixture_read("netsh_with_single_interface6") }

      let(:exec_cmd) do
        "#{described_class::NETSH} interface ipv6 show address \"#{interface}\""
      end

      it { expect(value_for_interface_and_label).to eq expected_ip }
    end
  end
end
