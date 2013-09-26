# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/windows'

describe Facter::Util::IP::Windows do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns('windows')
  end

  describe ".to_s" do
    let(:to_s) { described_class.to_s }

    it { to_s.should eq 'windows' }
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it { convert_netmask_from_hex?.should be false }
  end

  describe ".bonding_master" do
    let(:bonding_master) { described_class.bonding_master('eth0') }

    pending("porting to Windows") do
      it { bonding_master.should be_nil }
    end
  end

  describe ".interfaces" do
    let(:name)       { 'Local Area Connection' }
    let(:index)      { 7 }
    let(:nic_config) { mock('nic_config', :Index => index) }
    let(:nic)        { stub('nic', :NetConnectionId => name ) }
    let(:nic_empty_NetConnectionId)        { stub('nic', :NetConnectionId => '' ) }
    let(:nic_nil_NetConnectionId)        { stub('nic', :NetConnectionId => nil ) }
    let(:wmi_query) {"SELECT * FROM Win32_NetworkAdapter WHERE Index = #{index} AND NetEnabled = TRUE"}

    it "should return an array of only connected interfaces" do
      Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).
        returns([nic_config])
      Facter::Util::WMI.expects(:execquery).with(wmi_query).
        returns([nic])

      described_class.interfaces.should == [name]
    end

    it "should not return an interface with an empty NetConnectionId" do
      Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).
        returns([nic_config])
      Facter::Util::WMI.expects(:execquery).with(wmi_query).
        returns([nic_empty_NetConnectionId])

      described_class.interfaces.should == []
    end

    it "should not return an interface with a nil NetConnectionId" do
      Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).
        returns([nic_config])
      Facter::Util::WMI.expects(:execquery).with(wmi_query).
        returns([nic_nil_NetConnectionId])

      described_class.interfaces.should == []
    end

    context "when the adapter configuration is enabled but the underlying adapter is not enabled" do
      it "should not return an interface" do
        Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).
          returns([nic_config])
        Facter::Util::WMI.expects(:execquery).with(wmi_query).
          returns([])

        described_class.interfaces.should == []
      end
    end
  end
end
