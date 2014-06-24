#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ec2'

describe Facter::Util::EC2 do
  before do
    # Squelch deprecation notices
    Facter.stubs(:warnonce)
  end
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
        Facter::Core::Execution.expects(:exec).with("arp -an").\
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == true
      end

      it "should succeed if arp table contains FE:FF:FF:FF:FF:FF" do
        ec2arp = my_fixture_read("centos-arp-ec2.out")
        Facter::Core::Execution.expects(:exec).with("arp -an").\
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == true
      end

      it "should fail if arp table does not contain fe:ff:ff:ff:ff:ff" do
        ec2arp = my_fixture_read("linux-arp-not-ec2.out")
        Facter::Core::Execution.expects(:exec).with("arp -an").
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
        Facter::Core::Execution.expects(:exec).with("arp -a").\
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == true
      end

      it "should fail if arp table does not contain fe-ff-ff-ff-ff-ff" do
        ec2arp = my_fixture_read("windows-2008-arp-a-not-ec2.out")
        Facter::Core::Execution.expects(:exec).with("arp -a").
          at_least_once.returns(ec2arp)
        Facter::Util::EC2.has_ec2_arp?.should == false
      end
    end

    describe "on solaris" do
      before :each do
        Facter.stubs(:value).with(:kernel).returns("SunOS")
      end

      it "should fail if arp table does not contain fe:ff:ff:ff:ff:ff" do
        ec2arp = my_fixture_read("solaris8_arp_a_not_ec2.out")

        Facter::Core::Execution.expects(:exec).with("arp -a").
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

  describe "is_openstack_mac? method" do
    it "should return true when the mac is an openstack one" do
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("02:16:3e:54:89:fd")

      Facter::Util::EC2.has_openstack_mac?.should == true
    end

    it "should return true when the mac is a newer openstack mac" do
      # https://github.com/openstack/nova/commit/b684d651f540fc512ced58acd5ae2ef4d55a885c#nova/utils.py
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("fa:16:3e:54:89:fd")

      Facter::Util::EC2.has_openstack_mac?.should == true
    end

    it "should return true when the mac is a newer openstack mac and returned in upper case" do
      # https://github.com/openstack/nova/commit/b684d651f540fc512ced58acd5ae2ef4d55a885c#nova/utils.py
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("FA:16:3E:54:89:FD")

      Facter::Util::EC2.has_openstack_mac?.should == true
    end

    it "should return false when the mac is not a openstack one" do
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("0c:1d:a0:bc:aa:02")

      Facter::Util::EC2.has_openstack_mac?.should == false
    end
  end

  describe "can_connect? method" do
    it "returns true if api responds" do
      # Return something upon connecting to the root
      Module.any_instance.expects(:open).with("#{api_prefix}:80/").
        at_least_once.returns("2008-02-01\nlatest")

      Facter::Util::EC2.can_connect?.should be_true
    end

    describe "when connection times out" do
      it "should return false" do
        # Emulate a timeout when connecting by throwing an exception
        Module.any_instance.expects(:open).with("#{api_prefix}:80/").
          at_least_once.raises(RuntimeError)

        Facter::Util::EC2.can_connect?.should be_false
      end
    end

    describe "when connection is refused" do
      it "should return false" do
        # Emulate a connection refused
        Module.any_instance.expects(:open).with("#{api_prefix}:80/").
          at_least_once.raises(Errno::ECONNREFUSED)

        Facter::Util::EC2.can_connect?.should be_false
      end
    end
  end

  describe "Facter::Util::EC2.userdata" do
    let :not_found_error do
      OpenURI::HTTPError.new("404 Not Found", StringIO.new)
    end

    let :example_userdata do
      "owner=jeff@puppetlabs.com\ngroup=platform_team"
    end

    it 'returns nil when no userdata is present' do
      Facter::Util::EC2.stubs(:read_uri).raises(not_found_error)
      Facter::Util::EC2.userdata.should be_nil
    end

    it "returns the string containing the body" do
      Facter::Util::EC2.stubs(:read_uri).returns(example_userdata)
      Facter::Util::EC2.userdata.should == example_userdata
    end

    it "uses the specified API version" do
      expected_uri = "http://169.254.169.254/2008-02-01/user-data/"
      Facter::Util::EC2.expects(:read_uri).with(expected_uri).returns(example_userdata)
      Facter::Util::EC2.userdata('2008-02-01').should == example_userdata
    end
  end
end
