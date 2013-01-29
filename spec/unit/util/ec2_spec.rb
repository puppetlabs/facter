#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ec2'

describe Facter::Util::EC2 do
  # This is the standard prefix for making an API call in EC2 (or fake)
  # environments.
  let(:api_prefix) { "http://169.254.169.254" }

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

  describe "Facter::Util::EC2.with_metadata_server" do
    before :each do
      Facter::Util::EC2.stubs(:read_uri).returns("latest")
    end

    subject do
      Facter::Util::EC2.with_metadata_server do
        "HELLO FROM THE CODE BLOCK"
      end
    end

    it 'returns false when not running on xenu' do
      Facter.stubs(:value).with('virtual').returns('vmware')
      subject.should be_false
    end

    context 'default options and running on a xenu virtual machine' do
      before :each do
        Facter.stubs(:value).with('virtual').returns('xenu')
      end
      it 'returns the value of the block when the metadata server responds' do
        subject.should == "HELLO FROM THE CODE BLOCK"
      end
      it 'returns false when the metadata server is unreachable' do
        described_class.stubs(:read_uri).raises(Errno::ENETUNREACH)
        subject.should be_false
      end
      it 'does not execute the block if the connection raises an exception' do
        described_class.stubs(:read_uri).raises(Timeout::Error)
        myvar = "The block didn't get called"
        described_class.with_metadata_server do
          myvar = "The block was called and should not have been."
        end.should be_false
        myvar.should == "The block didn't get called"
      end
      it 'succeeds on the third retry' do
        retry_metadata = sequence('metadata')
        Timeout.expects(:timeout).twice.in_sequence(retry_metadata).raises(Timeout::Error)
        Timeout.expects(:timeout).once.in_sequence(retry_metadata).returns(true)
        subject.should == "HELLO FROM THE CODE BLOCK"
      end
    end
  end
end
