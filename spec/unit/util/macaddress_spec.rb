#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/macaddress'

describe "standardized MAC address" do
  it "should have zeroes added if missing" do
    Facter::Util::Macaddress::standardize("0:ab:cd:e:12:3").should == "00:ab:cd:0e:12:03"
  end

  it "should be identical if each octet already has two digits" do
    Facter::Util::Macaddress::standardize("00:ab:cd:0e:12:03").should == "00:ab:cd:0e:12:03"
  end

  it "should be nil if input is nil" do
    proc { result = Facter::Util::Macaddress.standardize(nil) }.should_not raise_error
    Facter::Util::Macaddress.standardize(nil).should be_nil
  end
end

describe "Darwin", :unless => Facter::Util::Config.is_windows? do
  test_cases = [
    # version,           iface, real macaddress,     fallback macaddress
    ["9.8.0",            'en0', "00:17:f2:06:e4:2e", "00:17:f2:06:e4:2e"],
    ["10.3.0",           'en0', "00:17:f2:06:e3:c2", "00:17:f2:06:e3:c2"],
    ["10.6.4",           'en1', "58:b0:35:7f:25:b3", "58:b0:35:fa:08:b1"],
    ["10.6.6_dualstack", "en1", "00:25:00:48:19:ef", "00:25:4b:ca:56:72"]
  ]

  test_cases.each do |version, default_iface, macaddress, fallback_macaddress|
    netstat_file = fixtures("netstat", "darwin_#{version.tr('.', '_')}")
    ifconfig_file_no_iface = fixtures("ifconfig", "darwin_#{version.tr('.', '_')}")
    ifconfig_file = "#{ifconfig_file_no_iface}_#{default_iface}"

    describe "version #{version}" do
      describe Facter::Util::Macaddress::Darwin do
        describe ".default_interface" do
          describe "when netstat has a default interface" do
            before do
              Facter::Util::Macaddress::Darwin.stubs(:netstat_command).returns("cat \"#{netstat_file}\"")
            end

            it "should return the default interface name" do
              Facter::Util::Macaddress::Darwin.default_interface.should == default_iface
            end
          end
        end

        describe ".macaddress" do
          describe "when netstat has a default interface" do
            before do
              Facter.stubs(:warn)
              Facter::Util::Macaddress::Darwin.stubs(:default_interface).returns('')
              Facter::Util::Macaddress::Darwin.stubs(:ifconfig_command).returns("cat \"#{ifconfig_file}\"")
            end

            it "should return the macaddress of the default interface" do
              Facter::Util::Macaddress::Darwin.macaddress.should == macaddress
            end
          end

          describe "when netstat does not have a default interface" do
            before do
              Facter::Util::Macaddress::Darwin.stubs(:default_interface).returns("")
              Facter::Util::Macaddress::Darwin.stubs(:ifconfig_command).returns("cat \"#{ifconfig_file_no_iface}\"")
            end

            it "should warn about the lack of default" do
              Facter.expects(:warn).with("Could not find a default route. Using first non-loopback interface")
              Facter::Util::Macaddress::Darwin.macaddress
            end

            it "should return the macaddress of the first non-loopback interface" do
              Facter.expects(:warn).with("Could not find a default route. Using first non-loopback interface")
              Facter::Util::Macaddress::Darwin.macaddress.should == fallback_macaddress
            end
          end
        end
      end
    end
  end
end

describe "The macaddress fact" do
  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
    require 'facter_spec/windows_network'

    include FacterSpec::WindowsNetwork

    before :each do
      Facter.fact(:kernel).stubs(:value).returns('windows')
      Facter.fact(:operatingsystem).stubs(:value).returns('windows')
      Facter.fact(:osfamily).stubs(:value).returns('windows')
      Facter::Util::Registry.stubs(:hklm_read).returns(nic_bindings)
    end

    describe "when you have no active network adapter" do
      it "should return nil if there are no active (or any) network adapters" do
        Facter::Util::WMI.expects(:execquery).returns([])

        Facter.value(:macaddress).should == nil
      end
    end

    describe "when you have one network adapter" do
      it "should return properly" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:macaddress).should == macAddress0
      end
    end

    describe "when you have more than one network adapter" do
      it "should return the macaddress of the adapter with the lowest IP connection metric (best connection)" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:macaddress).should == macAddress1
      end

      context "when the IP connection metric is the same" do
        it "should return the macaddress of the adapter with the lowest binding order" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:macaddress).should == macAddress0
        end

        it "should return the macaddress of the adapter with the lowest MACAddress when multiple adapters have the same IP connection metric when the lowest MACAddress is not first" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])

          Facter.value(:macaddress).should == macAddress1
        end
      end
    end
  end
end
