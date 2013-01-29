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

      # The stubs above this line may not be necessary any
      # longer.
      Facter::Util::EC2.stubs(:read_uri).
        with('http://169.254.169.254').returns('OK')
      Facter.stubs(:value).
        with('virtual').returns('xenu')
    end

    let :util do
      Facter::Util::EC2
    end

    it "defines facts dynamically from meta-data/" do
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/").
        returns("some_key_name")
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/some_key_name").
        at_least_once.returns("some_key_value")

      Facter::Util::EC2.add_ec2_facts(:force => true)

      Facter.fact(:ec2_some_key_name).
        value.should == "some_key_value"
    end

    it "defines fact values with comma separation" do
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/").
        returns("some_key_name")
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/some_key_name").
        at_least_once.returns("bar\nbaz")

      Facter::Util::EC2.add_ec2_facts(:force => true)

      Facter.fact(:ec2_some_key_name).
        value.should == "bar,baz"
    end

    it "should create structured meta-data facts" do
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/").
        returns("foo/")
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/foo/").
        at_least_once.returns("bar")
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/foo/bar").
        at_least_once.returns("baz")

      Facter::Util::EC2.add_ec2_facts(:force => true)

      Facter.fact(:ec2_foo_bar).value.should == "baz"
    end

    it "should create ec2_userdata fact" do
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/meta-data/").
        returns("")
      util.stubs(:read_uri).
        with("#{api_prefix}/latest/user-data/").
        at_least_once.returns("test")

      Facter::Util::EC2.add_ec2_facts(:force => true)

      Facter.fact(:ec2_userdata).value.should == ["test"]
    end
  end
end
