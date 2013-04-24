# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/hpux'

describe Facter::Util::IP::HPUX do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
  end

  describe ".to_s" do
    let :to_s do
      described_class.to_s
    end

    it "should be 'HP-UX'" do
      expect(to_s).to eq 'HP-UX'
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
    let :bonding_master do
      described_class.bonding_master('eth0')
    end

    it { expect(bonding_master).to be_nil }
  end

  describe ".interfaces" do
    let :interfaces do
      described_class.interfaces
    end

    before :each do
      described_class.stubs(:exec).with(anything).returns(netstat_output)
    end

    describe "version 11.11" do
      let :netstat_output do
        my_fixture_read("1111_netstat_in")
      end

      it "should return an array of interfaces" do
        expect(interfaces).to eq %w[lan1 lan0 lo0]
      end
    end

    describe "version 11.31" do
      let :netstat_output do
        my_fixture_read("1131_netstat_in")
      end

      it "should return an array of interfaces" do
        expect(interfaces).to eq %w[lan1 lan0 lo0]
      end
    end
  end

  describe ".value_for_interface_and_label(interface, label)" do
    let :value_for_interface_and_label do
      described_class.value_for_interface_and_label interface, label
    end

    describe "version 11.11" do
      let(:ifconfig_output) { my_fixture_read("1111_ifconfig_#{interface}") }
      let(:lanscan_output) { my_fixture_read("1111_lanscan") }

      before :each do
        described_class.stubs(:exec).returns(ifconfig_output)
      end

      describe "lan1" do
        let(:interface) { 'lan1' }

        describe "ipaddress" do
          let(:label) { 'ipaddress' }

          it { expect(value_for_interface_and_label).to eq '10.1.1.6' }
        end

        describe "mtu" do
          let(:label) { 'mtu' }

          it { pending "(#17808) MTU has not been implemented for HP-UX" }
        end

        describe "netmask" do
          let(:label) { 'netmask' }

          it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
        end

        describe "macaddress" do
          let(:label) { 'macaddress' }

          before :each do
            described_class.expects(:lanscan).returns(lanscan_output)
          end

          it { expect(value_for_interface_and_label).to eq "00:10:79:7B:5C:DE" }
        end
      end

      describe "lan0" do
        let(:interface) { 'lan0' }

        describe "ipaddress" do
          let(:label) { 'ipaddress' }

          it { expect(value_for_interface_and_label).to eq "192.168.3.10" }
        end

        describe "mtu" do
          let(:label) { 'mtu' }

          it { pending "(#17808) MTU has not been implemented for HP-UX" }
        end

        describe "netmask" do
          let(:label) { 'netmask' }

          it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
        end

        describe "macaddress" do
          let(:label) { 'macaddress' }

          before :each do
            described_class.expects(:lanscan).returns(lanscan_output)
          end

          it { expect(value_for_interface_and_label).to eq "00:30:7F:0C:79:DC" }
        end
      end

      describe "lo0" do
        let(:interface) { 'lo0' }

        describe "ipaddress" do
          let(:label) { 'ipaddress' }

          it { expect(value_for_interface_and_label).to eq "127.0.0.1" }
        end

        describe "mtu" do
          let(:label) { 'mtu' }

          it { pending "(#17808) MTU has not been implemented for HP-UX" }
        end

        describe "netmask" do
          let(:label) { 'netmask' }

          it { expect(value_for_interface_and_label).to eq '255.0.0.0' }
        end

        describe "macaddress" do
          let(:label) { 'macaddress' }

          it { expect(value_for_interface_and_label).to be_nil }
        end
      end
    end

    describe "version 11.31" do
      describe "when interfaces are normal" do
        let(:ifconfig_output) { my_fixture_read("1131_ifconfig_#{interface}") }
        let(:lanscan_output) { my_fixture_read("1131_lanscan") }

        before :each do
          described_class.stubs(:exec).returns(ifconfig_output)
        end

        describe "lan1" do
          let(:interface) { 'lan1' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '10.1.54.36' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:17:FD:2D:2A:57' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lan0" do
          let(:interface) { 'lan0' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '192.168.30.152' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:12:31:7D:62:09' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lo0" do
          let(:interface) { 'lo0' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '127.0.0.1' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.0.0.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to be_nil }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end
      end

      describe "when an interface has an asterisk appended" do
        let(:lanscan_output) { my_fixture_read("1131_asterisk_lanscan") }

        let :ifconfig_output do
          my_fixture_read "1131_asterisk_ifconfig_#{interface}"
        end

        before :each do
          described_class.stubs(:exec).returns(ifconfig_output)
        end

        describe "lan1" do
          let(:interface) { 'lan1' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '10.10.0.5' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:10:79:7B:BE:46' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lan0" do
          let(:interface) { 'lan0' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '192.168.3.9' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:30:5D:06:26:B2' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lo0" do
          let(:interface) { 'lo0' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '127.0.0.1' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.0.0.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to be_nil }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end
      end

      describe "when an interface is bonded and has one virtual interface" do
        let(:lanscan_output) { my_fixture_read "1131_nic_bonding_lanscan" }

        let :ifconfig_output do
          my_fixture_read "1131_nic_bonding_ifconfig_#{interface.sub(':', '_')}"
        end

        before :each do
          described_class.stubs(:exec).returns(ifconfig_output)
        end

        describe "lan1" do
          let(:interface) { 'lan1' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '192.168.30.32' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:12:81:9E:48:DE' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lo0" do
          let(:interface) { 'lo0' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '127.0.0.1' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.0.0.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to be_nil }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lan4" do
          let(:interface) { 'lan4' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '192.168.32.75' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }
            let(:macaddress) { '00:12:81:9E:4A:7E' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to eq macaddress }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end

        describe "lan4:1" do
          let(:interface) { 'lan4:1' }

          describe "ipaddress" do
            let(:label) { 'ipaddress' }

            it { expect(value_for_interface_and_label).to eq '192.168.1.197' }
          end

          describe "netmask" do
            let(:label) { 'netmask' }

            it { expect(value_for_interface_and_label).to eq '255.255.255.0' }
          end

          describe "macaddress" do
            let(:label) { 'macaddress' }

            before :each do
              described_class.expects(:lanscan).returns(lanscan_output)
            end

            it { expect(value_for_interface_and_label).to be_nil }
          end

          describe "mtu" do
            let(:label) { 'mtu' }

            it { pending "(#17808) MTU has not been implemented for HP-UX" }
          end
        end
      end
    end
  end
end
