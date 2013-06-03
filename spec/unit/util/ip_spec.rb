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

	describe ".parse_inet_address" do
    it "should parse out an ipaddress v4 format" do
    	Facter::Util::IP.parse_inet_address("ural0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        lladdr 00:0d:0b:ed:84:fb
        media: IEEE802.11 DS2 mode 11b hostap (autoselect mode 11b hostap)
        status: active
        ieee80211: nwid ARK chan 11 bssid 00:0d:0b:ed:84:fb  100dBm
        inet 218.72.98.97 netmask 0xffffff00 broadcast 218.72.98.97
        inet6 fe80::20d:bff:feed:84fb%ural0 prefixlen 64 scopeid 0xa"
        ).should eq "218.72.98.97"
        Facter::Util::IP.parse_inet_address("eth0 Link encap:Ethernet HWaddr 00:xx:xx:CB:4B:2B 
				inet addr:218.72.98.97 Bcast:218.72.98.97 Mask:218.72.98.97
				inet6 addr: xxxx::xxx:xxxx:xxxx:xxxx/64 Scope:Link
				UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
				RX packets:23666380 errors:0 dropped:0 overruns:0 frame:0
				TX packets:10898 errors:0 dropped:0 overruns:0 carrier:0
				collisions:0 txqueuelen:0 
				RX bytes:3430295711 (3.1 GiB) TX bytes:457932 (447.1 KiB)"
				).should eq "218.72.98.97"
		end
  	it "should not return an invalid ip address" do
    	Facter::Util::IP.parse_inet_address("ural0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        lladdr 00:0d:0b:ed:84:fb
        media: IEEE802.11 DS2 mode 11b hostap (autoselect mode 11b hostap)
        status: active
        ieee80211: nwid ARK chan 11 bssid 00:0d:0b:ed:84:fb  100dBm
        inet 999.999.999.999 netmask 0xffffff00 broadcast 999.999.999.999
        inet6 fe80::20d:bff:feed:84fb%ural0 prefixlen 64 scopeid 0xa"
        ).should be_nil
      Facter::Util::IP.parse_inet_address("eth0 Link encap:Ethernet HWaddr 00:xx:xx:CB:4B:2B 
				inet addr:999.999.999.999 Bcast:999.999.999.999 Mask:999.999.999.999
				inet6 addr: xxxx::xxx:xxxx:xxxx:xxxx/64 Scope:Link
				UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
				RX packets:23666380 errors:0 dropped:0 overruns:0 frame:0
				TX packets:10898 errors:0 dropped:0 overruns:0 carrier:0
				collisions:0 txqueuelen:0 
				RX bytes:3430295711 (3.1 GiB) TX bytes:457932 (447.1 KiB)"
				).should be_nil
		end
    it "should not return addresses starting with 127" do
    	Facter::Util::IP.parse_inet_address("ural0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        lladdr 00:0d:0b:ed:84:fb
        media: IEEE802.11 DS2 mode 11b hostap (autoselect mode 11b hostap)
        status: active
        ieee80211: nwid ARK chan 11 bssid 00:0d:0b:ed:84:fb  100dBm
        inet 127.72.98.97 netmask 0xffffff00 broadcast 127.72.98.97
        inet6 fe80::20d:bff:feed:84fb%ural0 prefixlen 64 scopeid 0xa").should be_nil
      Facter::Util::IP.parse_inet_address("eth0 Link encap:Ethernet HWaddr 00:xx:xx:CB:4B:2B 
				inet addr:127.72.98.97 Bcast:127.72.98.97 Mask:127.72.98.97
				inet6 addr: xxxx::xxx:xxxx:xxxx:xxxx/64 Scope:Link
				UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
				RX packets:23666380 errors:0 dropped:0 overruns:0 frame:0
				TX packets:10898 errors:0 dropped:0 overruns:0 carrier:0
				collisions:0 txqueuelen:0 
				RX bytes:3430295711 (3.1 GiB) TX bytes:457932 (447.1 KiB)").should be_nil 
    end
    it "should not return 0.0.0.0 addresses" do
    	Facter::Util::IP.parse_inet_address("ural0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        lladdr 00:0d:0b:ed:84:fb
        media: IEEE802.11 DS2 mode 11b hostap (autoselect mode 11b hostap)
        status: active
        ieee80211: nwid ARK chan 11 bssid 00:0d:0b:ed:84:fb  100dBm
        inet 0.0.0.0 netmask 0xffffff00 broadcast 0.0.0.0
        inet6 fe80::20d:bff:feed:84fb%ural0 prefixlen 64 scopeid 0xa").should be_nil
      Facter::Util::IP.parse_inet_address("eth0 Link encap:Ethernet HWaddr 00:xx:xx:CB:4B:2B 
				inet addr:0.0.0.0 Bcast:0.0.0.0 Mask:0.0.0.0
				inet6 addr: xxxx::xxx:xxxx:xxxx:xxxx/64 Scope:Link
				UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
				RX packets:23666380 errors:0 dropped:0 overruns:0 frame:0
				TX packets:10898 errors:0 dropped:0 overruns:0 carrier:0
				collisions:0 txqueuelen:0 
				RX bytes:3430295711 (3.1 GiB) TX bytes:457932 (447.1 KiB)").should be_nil 
    end
    describe "if we pass in 'nil'" do
      it "should not blow up" do
        lambda {
      	  Facter::Util::IP.parse_inet_address nil
        }.should_not raise_error
      end
      it "should return 'nil'" do
        Facter::Util::IP.parse_inet_address(nil).should be_nil
      end

    end
    describe "if we pass in non-string input" do
    	it "should not blow up" do
        lambda {
      	  Facter::Util::IP.parse_inet_address 127
        }.should_not raise_error
      end
      it "should return 'nil'" do
        Facter::Util::IP.parse_inet_address(127).should be_nil
      end
    end
    it "should return 'nil' for empty string" do
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
