#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

describe "ipaddress fact" do
  before do
    Facter.collection.internal_loader.load(:ipaddress)
  end

  context 'using `ifconfig`' do
    context "on Linux" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
      end

      def expect_ifconfig_parse(address, fixture)
        Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
        Facter.fact(:ipaddress).value.should == address
      end

      it "parses correctly on Ubuntu 12.04" do
        expect_ifconfig_parse "10.87.80.110", "ifconfig_ubuntu_1204.txt"
      end

      it "parses correctly on Fedora 17" do
        expect_ifconfig_parse "131.252.209.153", "ifconfig_net_tools_1.60.txt"
      end

      it "parses a real address over multiple loopback addresses" do
        expect_ifconfig_parse "10.0.222.20", "ifconfig_multiple_127_addresses.txt"
      end

      it "parses nothing with a non-english locale" do
        expect_ifconfig_parse nil, "ifconfig_non_english_locale.txt"
      end
    end
  end
end
