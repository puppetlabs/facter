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
    it "executes /sbin/ifconfig when get_ifconfig() returns /sbin/ifconfig" do
      Facter::Util::IP.expects(:get_ifconfig).returns("/sbin/ifconfig")
      Facter::Util::Resolution.expects(:exec).with("/sbin/ifconfig")
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
      expect(Facter.fact(:interfaces)).to be_a_kind_of Facter::Util::Fact
    end

    it "defines a fact for each attribute of an interface" do
      interfaces_hash.keys.each do |interface|
        described_class::INTERFACE_KEYS.each do |attr|
          expect(Facter.fact("#{attr}_#{interface}")).
            to be_a_kind_of Facter::Util::Fact
        end
      end
    end

    it "defines a fact for an interface's network" do
      interfaces_hash.keys.each do |interface|
        expect(Facter.fact("network_#{interface}")).
          to be_a_kind_of Facter::Util::Fact
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
        expect(Facter.value(:interfaces)).to eq interfaces_hash.keys.join(',')
      end

      it 'defines dynamic facts for the interfaces' do
        interfaces_hash.keys.each do |interface|
          described_class::INTERFACE_KEYS.each do |attr|
            expect(Facter.value("#{attr}_#{interface}")).
              to eq interfaces_hash[interface][attr]
          end
        end
      end

      it 'defines a dynamic fact for the interfaces networks' do
        interfaces_hash.keys.each do |interface|
          expect(Facter.value("network_#{interface}")).
            to eq interfaces_hash[interface][:network]
        end
      end
    end

    describe "when interface facts have been flushed after being resolved" do
      before :each do
        given_initial_interfaces_facts
        when_interfaces_facts_have_been_resolved_then_flushed
      end

      it "updates the interfaces fact" do
        expect(Facter.value(:interfaces)).to eq interfaces_hash2.keys.join(',')
      end

      it "defines new dynamic facts for the new interfaces attributes" do
        interfaces_hash2.keys.each do |interface|
          described_class::INTERFACE_KEYS.each do |attr|
            expect(Facter.value("#{attr}_#{interface}")).
              to eq interfaces_hash2[interface][attr]
          end
        end
      end

      it "defines a new dynamic fact for the new interfaces network" do
        interfaces_hash2.keys.each do |interface|
          expect(Facter.value("network_#{interface}")).
            to eq interfaces_hash2[interface][:network]
        end
      end
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
