#!/usr/bin/env rspec

require 'spec_helper'

describe "ec2 facts" do
  let(:api_prefix) { "http://169.254.169.254" }

  describe "when running on ec2" do
    before :each do
      # Return fake kernel
      Facter.stubs(:value).with(:kernel).returns("Linux")

      # Return something upon connecting to the root so the EC2 code continues
      # with its evaluation.
      Object.any_instance.expects(:open).with("#{api_prefix}:80/").\
        at_least_once.returns("2008-02-01\nlatest")

      # Return a non-eucalyptus mac address
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("12:31:39:04:5A:34")

      # Fake EC2 arp response
      ec2arp = "? (10.240.93.1) at fe:ff:ff:ff:ff:ff [ether] on eth0\n"
      Facter::Util::Resolution.expects(:exec).with("arp -an").\
        at_least_once.returns(ec2arp)
    end

    it "should create flat meta-data facts" do
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new("foo"))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/foo").\
        at_least_once.returns(StringIO.new("bar"))

      # No user-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/user-data/").\
        at_least_once.returns(StringIO.new(""))

      Facter.collection.loader.load(:ec2)
      Facter.fact(:ec2_foo).value.should == "bar"
    end

    it "should create flat meta-data facts with comma seperation" do
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new("foo"))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/foo").\
        at_least_once.returns(StringIO.new("bar\nbaz"))

      # No user-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/user-data/").\
        at_least_once.returns(StringIO.new(""))

      Facter.collection.loader.load(:ec2)
      Facter.fact(:ec2_foo).value.should == "bar,baz"
    end

    it "should create structured meta-data facts" do
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new("foo/"))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/foo/").\
        at_least_once.returns(StringIO.new("bar"))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/foo/bar").\
        at_least_once.returns(StringIO.new("baz"))

      # No user-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/user-data/").\
        at_least_once.returns(StringIO.new(""))

      Facter.collection.loader.load(:ec2)
      Facter.fact(:ec2_foo_bar).value.should == "baz"
    end

    it "should create ec2_user_data fact" do
      # No meta-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new(""))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/user-data/").\
        at_least_once.returns(StringIO.new("test"))

      Facter.collection.loader.load(:ec2)
      Facter.fact(:ec2_userdata).value.should == ["test"]
    end
  end

  describe "when running on eucalyptus" do
    before :each do
      # Return fake kernel
      Facter.stubs(:value).with(:kernel).returns("Linux")

      # Return something upon connecting to the root so the EC2 code continues
      # with its evaluation.
      Object.any_instance.expects(:open).with("#{api_prefix}:80/").\
        at_least_once.returns("2008-02-01\nlatest")

      # Return a eucalyptus mac address
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("d0:0d:1a:b0:a1:00")
    end

    it "should create ec2_user_data fact" do
      # No meta-data
      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/meta-data/").\
        at_least_once.returns(StringIO.new(""))

      Object.any_instance.expects(:open).\
        with("#{api_prefix}/2008-02-01/user-data/").\
        at_least_once.returns(StringIO.new("test"))

      Facter.collection.loader.load(:ec2)
      Facter.fact(:ec2_userdata).value.should == ["test"]
    end
  end

  describe "when ec2 url times out" do
    before :each do
      # Return fake kernel
      Facter.stubs(:value).with(:kernel).returns("Linux")

      # Emulate a timeout when connecting by throwing an exception
      Object.any_instance.expects(:open).with("#{api_prefix}:80/").\
        at_least_once.raises(Timeout::Error)

      # Return a eucalyptus mac address
      Facter.expects(:value).with(:macaddress).\
        at_least_once.returns("d0:0d:1a:b0:a1:00")
    end

    it "should not raise exception" do
      expect { Facter.collection.loader.load(:ec2) }.to_not raise_error
    end
  end
end
