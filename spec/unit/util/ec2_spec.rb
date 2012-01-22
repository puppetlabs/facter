#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/ec2'

describe Facter::Util::EC2 do
  # This is the standard prefix for making an API call in EC2 (or fake)
  # environments.
  let(:api_prefix) { "http://169.254.169.254" }

  describe "is_ec2_arp? method" do
    describe "on linux" do
      before :each do
        # Return fake kernel
        Facter.stubs(:value).with(:kernel).returns("linux")
      end

      it "should succeed if arp table contains fe:ff:ff:ff:ff:ff" do
        ec2arp = my_fixture_read("linux-arp-ec2.out")
        Facter::Util::Resolution.expects(:exec).with("arp -an").\
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == true
      end

      it "should fail if arp table does not contain fe:ff:ff:ff:ff:ff" do
        ec2arp = my_fixture_read("linux-arp-not-ec2.out")
        Facter::Util::Resolution.expects(:exec).with("arp -an").
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == false
      end
    end

    describe "on windows" do
      before :each do
        # Return fake kernel
        Facter.stubs(:value).with(:kernel).returns("windows")
      end

      it "should succeed if arp table contains fe-ff-ff-ff-ff-ff" do
        ec2arp = my_fixture_read("windows-2008-arp-a.out")
        Facter::Util::Resolution.expects(:exec).with("arp -a").\
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == true
      end

      it "should fail if arp table does not contain fe-ff-ff-ff-ff-ff" do
        ec2arp = my_fixture_read("windows-2008-arp-a-not-ec2.out")
        Facter::Util::Resolution.expects(:exec).with("arp -a").
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == false
      end
    end
  end

  describe "is_euca_mac? method" do
    it "should return true when the mac is a eucalyptus one" do
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("d0:0d:1a:b0:a1:00")

      Facter::Util::EC2.has_euca_mac?.should == true
    end

    it "should return false when the mac is not a eucalyptus one" do
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("0c:1d:a0:bc:aa:02")

      Facter::Util::EC2.has_euca_mac?.should == false
    end
  end

  describe "can_connect? method" do
    it "returns true if api responds" do
      # Return something upon connecting to the root
      Module.any_instance.expects(:open).with("#{api_prefix}:80/").\
        at_least_once.returns("2008-02-01\nlatest")

      Facter::Util::EC2.can_connect?.should == true
    end

    describe "when connection times out" do
      before :each do
        # Emulate a timeout when connecting by throwing an exception
        Module.any_instance.expects(:open).with("#{api_prefix}:80/").\
          at_least_once.raises(Timeout::Error)
      end

      it "should not raise exception" do
        expect { Facter::Util::EC2.can_connect? }.to_not raise_error
      end

      it "should return false" do
        Facter::Util::EC2.can_connect?.should == false
      end
    end

    describe "when connection is refused" do
      before :each do
        # Emulate a connection refused
        Module.any_instance.expects(:open).with("#{api_prefix}:80/").\
          at_least_once.raises(Errno::ECONNREFUSED)
      end

      it "should not raise exception" do
        expect { Facter::Util::EC2.can_connect? }.to_not raise_error
      end

      it "should return false" do
        Facter::Util::EC2.can_connect?.should == false
      end
    end
  end
end
