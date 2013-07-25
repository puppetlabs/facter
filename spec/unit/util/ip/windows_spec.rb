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
    let(:nic)        { mock('nic', :NetConnectionId => name ) }

    it "should return an array of only connected interfaces" do
      Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).
        returns([nic_config])
      Facter::Util::WMI.expects(:execquery).with("SELECT * FROM Win32_NetworkAdapter WHERE Index = #{index}").
        returns([nic])

      described_class.interfaces.should == [name]
    end
  end
end
