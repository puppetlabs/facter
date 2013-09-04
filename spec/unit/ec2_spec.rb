#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ec2'

describe "ec2 facts" do
  # This is the standard prefix for making an API call in EC2 (or fake)
  # environments.
  let(:api_prefix) { "http://169.254.169.254" }

  describe "when running on ec2" do
    before :each do
      # This is an ec2 instance, not a eucalyptus instance
      Facter::Util::EC2.stubs(:has_euca_mac?).returns(false)
      Facter::Util::EC2.stubs(:has_openstack_mac?).returns(false)
      Facter::Util::EC2.stubs(:has_ec2_arp?).returns(true)

      # Assume we can connect
      Facter::Util::EC2.stubs(:can_connect?).returns(true)
    end

    it "should create flat meta-data facts" do
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").
        at_least_once.returns(StringIO.new("foo"))

      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/foo").
        at_least_once.returns(StringIO.new("bar"))

      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_foo).value.should == "bar"
    end

    it "should create flat meta-data facts with comma seperation" do
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").
        at_least_once.returns(StringIO.new("foo"))

      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/foo").
        at_least_once.returns(StringIO.new("bar\nbaz"))

      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_foo).value.should == "bar,baz"
    end

    it "should create structured meta-data facts" do
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").
        at_least_once.returns(StringIO.new("foo/"))

      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/foo/").
        at_least_once.returns(StringIO.new("bar"))

      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/foo/bar").
        at_least_once.returns(StringIO.new("baz"))

      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_foo_bar).value.should == "baz"
    end

    it "should create ec2_user_data fact" do
      # No meta-data
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").
        at_least_once.returns(StringIO.new(""))

      Facter::Util::EC2.stubs(:read_uri).
        with("#{api_prefix}/latest/user-data/").
        returns("test")

      Facter.collection.internal_loader.load(:ec2)
      Facter.fact(:ec2_userdata).value.should == ["test"]
    end
  end

  describe "when running on eucalyptus" do
    before :each do
      # Return false for ec2, true for eucalyptus
      Facter::Util::EC2.stubs(:has_euca_mac?).returns(true)
      Facter::Util::EC2.stubs(:has_openstack_mac?).returns(false)
      Facter::Util::EC2.stubs(:has_ec2_arp?).returns(false)

      # Assume we can connect
      Facter::Util::EC2.stubs(:can_connect?).returns(true)
    end

    it "should create ec2_user_data fact" do
      # No meta-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new(""))

      Facter::Util::EC2.stubs(:read_uri).
        with("#{api_prefix}/latest/user-data/").
        returns("test")

      # Force a fact load
      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_userdata).value.should == ["test"]
    end
  end

  describe "when running on openstack" do
    before :each do
      # Return false for ec2, true for eucalyptus
      Facter::Util::EC2.stubs(:has_openstack_mac?).returns(true)
      Facter::Util::EC2.stubs(:has_euca_mac?).returns(false)
      Facter::Util::EC2.stubs(:has_ec2_arp?).returns(false)

      # Assume we can connect
      Facter::Util::EC2.stubs(:can_connect?).returns(true)
    end

    it "should create ec2_user_data fact" do
      # No meta-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new(""))

      Facter::Util::EC2.stubs(:read_uri).
        with("#{api_prefix}/latest/user-data/").
        returns("test")

      # Force a fact load
      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_userdata).value.should == ["test"]
    end

    it "should return nil if open fails" do
      Facter.stubs(:warn) # do not pollute test output
      Facter.expects(:warn).with('Could not retrieve ec2 metadata: host unreachable')

      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").
        at_least_once.raises(RuntimeError, 'host unreachable')

      Facter::Util::EC2.stubs(:read_uri).
        with("#{api_prefix}/latest/user-data/").
        raises(RuntimeError, 'host unreachable')

      # Force a fact load
      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_userdata).value.should be_nil
    end

  end

  describe "when api connect test fails" do
    before :each do
      Facter.stubs(:warnonce)
    end

    it "should not populate ec2_userdata" do
      # Emulate ec2 for now as it matters little to this test
      Facter::Util::EC2.stubs(:has_euca_mac?).returns(true)
      Facter::Util::EC2.stubs(:has_ec2_arp?).never
      Facter::Util::EC2.expects(:can_connect?).at_least_once.returns(false)

      # The API should never be called at this point
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/meta-data/").never
      Object.any_instance.expects(:open).
        with("#{api_prefix}/2008-02-01/user-data/").never

      # Force a fact load
      Facter.collection.internal_loader.load(:ec2)

      Facter.fact(:ec2_userdata).should == nil
    end

    it "should rescue the exception" do
      Facter::Util::EC2.expects(:open).with("#{api_prefix}:80/").raises(Timeout::Error)

      Facter::Util::EC2.should_not be_can_connect
    end
  end
end
