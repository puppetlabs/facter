# encoding: UTF-8

require 'spec_helper'
require 'facter/util/ip/base'

describe Facter::Util::IP::Base do
  subject { described_class }

  describe ".subclasses" do
    let(:subclasses) { described_class.subclasses }

    it { subclasses.should be_an Array }

    it "should be memoized" do
      described_class.subclasses().should be described_class.subclasses()
    end

    it "should list subclasses" do
      subclass = Class.new described_class

      subclasses.should include subclass
    end
  end

  describe ".to_s" do
    let(:to_s) { described_class.to_s }

    it "should return the name of the class without nesting" do
      to_s.should eq 'Base'
    end
  end

  describe ".convert_netmask_from_hex?" do
    let :convert_netmask_from_hex? do
      described_class.convert_netmask_from_hex?
    end

    it { convert_netmask_from_hex?.should eq true }
  end

  describe ".bonding_master" do
    let(:bonding_master) { described_class.bonding_master('eth0') }

    it { bonding_master.should be_nil }
  end

  describe ".interfaces" do
    let(:interfaces) { described_class.interfaces }

    it "uses `ifconfig` to list the interfaces" do
      described_class.expects(:ifconfig_path).returns('/bin/ifconfig')
      described_class.expects(:exec).with("/bin/ifconfig -a 2> /dev/null")
      interfaces.should be_an Array
    end
  end

  describe ".value_for_interface_and_label(interface, label)" do
    let :value_for_interface_and_label do
      described_class.value_for_interface_and_label interface, label
    end

    let(:interface) { 'eth0' }

    describe "there is no regex for the label" do
      let(:label) { 'foobar' }

      before :each do
        described_class.expects(:regex_for).with(label).returns(nil)
      end

      it { value_for_interface_and_label.should be_nil }
    end

    describe "there is a regex for the label" do
      let(:regex) { // }
      let(:ifconfig_path) { '/usr/bin/ifconfig' }
      let(:exec_cmd) { "#{ifconfig_path} #{interface} 2> /dev/null" }
      let(:ifconfig_output) { "" }

      before :each do
        described_class.expects(:ifconfig_path).returns(ifconfig_path)
        described_class.expects(:regex_for).with(label).returns(regex)
        described_class.expects(:exec).with(exec_cmd).returns(ifconfig_output)
        regex.expects(:match).with(ifconfig_output).returns(match_data)
      end

      describe "there is a match with the exec output and the regex" do
        describe "the label is not 'netmask'" do
          let(:match_data) { ['inet 127.0.0.1', '127.0.0.1'] }
          let(:label) { 'ipaddress' }

          it { value_for_interface_and_label.should eq '127.0.0.1' }
        end

        describe "the label is 'netmask'" do
          let(:label) { 'netmask' }

          describe "the netmask needs to be converted from hex" do
            let(:match_data) { ['netmask ffffff00', 'ffffff00'] }

            before :each do
              described_class.expects(:convert_netmask_from_hex?).returns(true)
            end

            it { value_for_interface_and_label.should eq '255.255.255.0' }
          end

          describe "the netmask does not need to be converted from hex" do
            let(:match_data) { ['netmask 255.255.255.0', '255.255.255.0'] }

            before :each do
              described_class.expects(:convert_netmask_from_hex?).returns(false)
            end

            it { value_for_interface_and_label.should eq '255.255.255.0' }
          end
        end
      end

      describe "there is not a match with the exec output and the regex" do
        let(:match_data) { nil }
        let(:label) { 'ipaddress' }

        it { value_for_interface_and_label.should be_nil }
      end
    end

    describe ".network(interface)" do
      let(:network) { described_class.network(interface) }
      let(:interface) { 'e1000g0' }

      before :each do
        described_class.
          expects(:value_for_interface_and_label).
          with(interface, 'ipaddress').
          returns('172.16.15.138')

        described_class.
          expects(:value_for_interface_and_label).
          with(interface, 'netmask').
          returns('255.255.255.0')
      end

      it { network.should eq "172.16.15.0" }
    end
  end
end
