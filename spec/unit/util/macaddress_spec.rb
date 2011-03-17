#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/macaddress'

describe "Darwin" do
  test_cases = [
    # version,           iface, real macaddress,     fallback macaddress
    ["9.8.0",            'en0', "00:17:f2:06:e4:2e", "00:17:f2:06:e4:2e"],
    ["10.3.0",           'en0', "00:17:f2:06:e3:c2", "00:17:f2:06:e3:c2"],
    ["10.6.4",           'en1', "58:b0:35:7f:25:b3", "58:b0:35:fa:08:b1"],
    ["10.6.6_dualstack", "en1", "00:25:00:48:19:ef", "00:25:4b:ca:56:72"]
  ]

  test_cases.each do |version, default_iface, macaddress, fallback_macaddress|
    netstat_file = File.join(SPECDIR, "fixtures", "netstat", "darwin_#{version.tr('.', '_')}")
    ifconfig_file_no_iface = File.join(SPECDIR, "fixtures", "ifconfig", "darwin_#{version.tr('.', '_')}")
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
              Facter::Util::Macaddress::Darwin.stubs(:default_interface).returns('')
              Facter::Util::Macaddress::Darwin.macaddress
            end

            it "should return the macaddress of the first non-loopback interface" do
              Facter::Util::Macaddress::Darwin.macaddress.should == fallback_macaddress
            end
          end
        end
      end
    end
  end
end
