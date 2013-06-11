#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

describe Facter::Util::IP do
  let :interfaces_hash do
    {
      :eth0 => {
        :ipaddress => 1,
        :ipaddress6 => 2,
        :macaddress => 3,
        :netmask => 4,
        :mtu => 5,
        :network => 6
      },

      :lo0 => {
        :ipaddress => 7,
        :ipaddress6 => 8,
        :macaddress => 9,
        :netmask => 10,
        :mtu => 11,
        :network => 12
      }
    }
  end

  let :interfaces_hash2 do
    {
      :en1 => {
        :ipaddress => 13,
        :ipaddress6 => 14,
        :macaddress => 15,
        :netmask => 16,
        :mtu => 17,
        :network => 18
      },

      :lo => {
        :ipaddress => 19,
        :ipaddress6 => 20,
        :macaddress => 21,
        :netmask => 22,
        :mtu => 23,
        :network => 24
      }
    }
  end

  %w{
    FreeBSD Linux NetBSD OpenBSD SunOS Darwin HP-UX GNU/kFreeBSD windows
    Dragonfly
  }.each do |platform|
    it "should be supported on #{platform}" do
      Facter::Util::IP.new.supported_platforms.should include platform
    end
  end

  describe "exec_ifconfig" do
    it "uses get_ifconfig" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig").once

      Facter::Util::IP.exec_ifconfig
    end
    it "support additional arguments" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/ifconfig -a")

      Facter::Util::IP.exec_ifconfig(["-a"])
    end
    it "joins multiple arguments correctly" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/ifconfig -a -e -i -j")

      Facter::Util::IP.exec_ifconfig(["-a","-e","-i","-j"])
    end
  end

  describe ".add_interface_facts" do
    before :each do
      given_initial_interfaces_facts
      described_class.add_interface_facts
    end

    it "defines the 'interfaces' fact" do
      Facter.fact(:interfaces).should be_a_kind_of Facter::Util::Fact
    end

    it "defines a fact for each attribute of an interface" do
      interfaces_hash.keys.each do |interface|
        described_class::INTERFACE_KEYS.each do |attr|
          Facter.fact("#{attr}_#{interface}").should be_a_kind_of Facter::Util::Fact
        end
      end
    end

    it "defines a fact for an interface's network" do
      interfaces_hash.keys.each do |interface|
        Facter.fact("network_#{interface}").should be_a_kind_of Facter::Util::Fact
      end
    end
  end

  describe "multiple facts sharing a single model" do
    describe "when interfaces are resolved for the first time" do
      before :each do
        given_initial_interfaces_facts
        Facter.value(:interfaces)
      end

      it 'lists the interfaces for the interfaces fact' do
        Facter.value(:interfaces).should eq interfaces_hash.keys.join(',')
      end

      it 'defines dynamic facts for the interfaces' do
        interfaces_hash.keys.each do |interface|
          described_class::INTERFACE_KEYS.each do |attr|
            Facter.value("#{attr}_#{interface}").should eq interfaces_hash[interface][attr]
          end
        end
      end

      it 'defines a dynamic fact for the interfaces networks' do
        interfaces_hash.keys.each do |interface|
          Facter.value("network_#{interface}").should eq interfaces_hash[interface][:network]
        end
      end
    end

    describe "when interface facts have been flushed after being resolved" do
      before :each do
        given_initial_interfaces_facts
        when_interfaces_facts_have_been_resolved_then_flushed
      end

      it "updates the interfaces fact" do
        Facter.value(:interfaces).should eq interfaces_hash2.keys.join(',')
      end

      it "defines new dynamic facts for the new interfaces attributes" do
        interfaces_hash2.keys.each do |interface|
          described_class::INTERFACE_KEYS.each do |attr|
            Facter.value("#{attr}_#{interface}").should eq interfaces_hash2[interface][attr]
          end
        end
      end

      it "defines a new dynamic fact for the new interfaces network" do
        interfaces_hash2.keys.each do |interface|
          Facter.value("network_#{interface}").should eq interfaces_hash2[interface][:network]
        end
      end
    end
  end
	
	shared_examples_for "ifconfig output" do |platform, address, fixture|
		describe "correctly on #{platform}" do 	
			describe ".parse_inet_address" do
				it "should parse out an ipaddress v4 format" do
					Facter::Util::IP.parse_inet_address(my_fixture_read(fixture)).should eq address
				end
			end
		end
	end
	
	shared_examples_for "ifconfig output loopback only" do |platform, fixture|
		describe "correctly on #{platform}" do 	
			describe ".parse_inet_address" do
				it "should not return addresses starting with 127" do
	        Facter::Util::IP.parse_inet_address(my_fixture_read(fixture)).should be_nil
				end
			end
		end
	end
	
	shared_examples_for "ifconfig output bonding failure" do |platform, fixture|
		describe "correctly on #{platform}" do 	
			describe ".parse_inet_address" do
				it "should not return 0.0.0.0 addresses" do
	        Facter::Util::IP.parse_inet_address(my_fixture_read(fixture)).should be_nil
				end
			end
		end
	end
	
	RSpec.configure do |config|
  	config.alias_it_should_behave_like_to :example_behavior_for, "parses"
	end
	describe ".parse_inet_address" do
		example_behavior_for "ifconfig output",
    	"AIX","10.16.77.22", "aix/ifconfig_all_with_multiple_interfaces"
    example_behavior_for "ifconfig output",
    	"Darwin","192.168.0.10", "darwin/ifconfig_all_with_multiple_interfaces"
    example_behavior_for "ifconfig output",
    	"FreeBSD","192.10.58.26", "free_bsd/6.0-STABLE_ifconfig_with_multiple_interfaces"
    example_behavior_for "ifconfig output",
    	"GNU K FreeBSD","192.168.10.10", "gnu_k_free_bsd/ifconfig_all_with_multiple_interfaces"
    example_behavior_for "ifconfig output",
    	"HPUX","192.168.3.10", "hpux/1111_ifconfig_lan0"
    example_behavior_for "ifconfig output",
    	"Linux","172.16.15.133", "linux/ifconfig_all_with_single_interface"
    example_behavior_for "ifconfig output",
    	"Mac OS X 10.5.5","192.168.0.4", "Mac_OS_X_10.5.5_ifconfig"
		example_behavior_for "ifconfig output",
      "SunOS", "172.16.15.138", "sun_os/ifconfig_single_interface"
    example_behavior_for "ifconfig output",
    	"Solaris","10.16.77.145", "solaris/ifconfig_all_with_multiple_interfaces"
    	
    example_behavior_for "ifconfig output loopback only",
    	"AIX", "aix/ifconfig_single_interface_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"Darwin", "darwin/ifconfig_single_interface_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"FreeBSD", "free_bsd/ifconfig_single_interface_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"GNU K FreeBSD", "gnu_k_free_bsd/ifconfig_single_interface_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"HPUX", "hpux/1111_ifconfig_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"Linux", "linux/ifconfig_single_interface_lo"
    example_behavior_for "ifconfig output loopback only",
    	"Mac OS X 10.5.5", "Mac_OS_X_10.5.5_ifconfig_single_interface_lo0"
		example_behavior_for "ifconfig output loopback only",
      "SunOS", "sun_os/ifconfig_single_interface_lo0"
    example_behavior_for "ifconfig output loopback only",
    	"Solaris", "solaris/ifconfig_single_interface_lo0"
    	
    example_behavior_for "ifconfig output bonding failure",
    	"AIX", "aix/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"Darwin", "darwin/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"FreeBSD", "free_bsd/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"GNU K FreeBSD", "gnu_k_free_bsd/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"HPUX", "hpux/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"Linux", "linux/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"Mac OS X 10.5.5", "Mac_OS_X_10.5.5_ifconfig_with_single_interface_bonding_failure"
		example_behavior_for "ifconfig output bonding failure",
      "SunOS", "sun_os/ifconfig_with_single_interface_bonding_failure"
    example_behavior_for "ifconfig output bonding failure",
    	"Solaris", "solaris/ifconfig_with_single_interface_bonding_failure"
    		
		it "should fail if we pass 'nil'" do
				lambda { Facter::Util::IP.parse_inet_address(nil) }.should raise_error
		end
		it "should fail if we pass non-string input" do
			lambda { Facter::Util::IP.parse_inet_address(127) }.should raise_error
		end
		it "should return 'nil' if we pass empty string" do
			Facter::Util::IP.parse_inet_address("").should be_nil
		end
	end
  def given_initial_interfaces_facts
    model = described_class.new
    model.stubs(:interfaces).returns(interfaces_hash.keys)
    model.stubs(:parse!)
    model.interfaces_hash = interfaces_hash
    described_class.stubs(:new).returns(model)
  end

  def when_interfaces_facts_have_been_resolved_then_flushed
    interfaces_hash.keys.each do |interface|
      described_class::INTERFACE_KEYS.each do |attr|
        Facter.value("#{attr}_#{interface}")
      end
    end

    model = described_class.new
    model.stubs(:interfaces).returns(interfaces_hash2.keys)
    model.stubs(:parse!)
    model.interfaces_hash = interfaces_hash2
    described_class.stubs(:new).returns(model)

    Facter.flush
    Facter.value(:interfaces)
  end
end
