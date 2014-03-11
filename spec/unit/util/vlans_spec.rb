#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/vlans'

describe Facter::Util::Vlans do
  let(:vlan_file) { "/proc/net/vlan/config" }

  describe "reading the vlan configuration" do
    it "uses the contents of /proc/net/vlan/config" do
      File.expects(:exist?).with(vlan_file).returns true
      File.expects(:readable?).with(vlan_file).returns true
      File.expects(:read).with(vlan_file).returns "vlan contents here"

      expect(Facter::Util::Vlans.get_vlan_config).to eq "vlan contents here"
    end

    it "returns nil when /proc/net/vlan/config is absent" do
      File.expects(:exist?).with(vlan_file).returns false
      expect(Facter::Util::Vlans.get_vlan_config).to be_nil
    end
  end

  describe "parsing the vlan configuration" do
    let(:vlan_content) { my_fixture_read("linux_vlan_config") }

    it "returns a list of vlans on Linux when vlans are configured" do
      Facter::Util::Vlans.stubs(:get_vlan_config).returns(vlan_content)
      expect(Facter::Util::Vlans.get_vlans()).to eq %{400,300,200,100}
    end

    it "returns nil when no vlans are configured" do
      Facter::Util::Vlans.stubs(:get_vlan_config).returns(nil)
      expect(Facter::Util::Vlans.get_vlans()).to be_nil
    end

    it "returns nil when only the vlan header is returned" do
      Facter::Util::Vlans.stubs(:get_vlan_config).returns(my_fixture_read("centos-5-no-vlans"))
      expect(Facter::Util::Vlans.get_vlans()).to be_nil
    end
  end
end
