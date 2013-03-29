# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/dragonfly'

describe Facter::Util::IP::Dragonfly do
  describe ".to_s" do
    let :to_s do
      described_class.to_s
    end

    it "should be 'Dragonfly'" do
      expect(to_s).to eq 'Dragonfly'
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
    let(:bonding_master) do
      described_class.bonding_master('eth0')
    end

    it { expect(bonding_master).to be_nil }
  end
end
