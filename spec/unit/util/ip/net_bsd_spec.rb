# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/net_bsd'

describe Facter::Util::IP::NetBSD do
  describe ".to_s" do
    let :to_s do
      described_class.to_s
    end

    it "should be 'NetBSD'" do
      to_s.should eq 'NetBSD'
    end
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it "should be true" do
      convert_netmask_from_hex?.should be true
    end
  end

  describe ".bonding_master" do
    let :bonding_master do
      described_class.bonding_master('eth0')
    end

    it { bonding_master.should be_nil }
  end
end
