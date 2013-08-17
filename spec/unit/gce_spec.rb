#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/gce'

describe "gce facts" do
  # This is the standard prefix for making an API call in GCE (or fake)
  # environments.
  let(:api_prefix) { "http://metadata/computeMetadata" }
  let(:api_version) { "v1beta1" }

  describe "when running on gce" do
    before :each do
      # Assume we can connect
      Facter::Util::GCE.stubs(:can_connect?).returns(true)
      Facter::Util::GCE.stubs(:read_uri).
        with('http://metadata').returns('OK')
      Facter.stubs(:value).
        with('virtual').returns('gce')
    end

    let :util do
      Facter::Util::GCE
    end

    it "defines facts dynamically from metadata/" do
      util.stubs(:read_uri).
        with("#{api_prefix}/#{api_version}/?recursive=true&alt=json").
        returns('{"some_key_name":"some_key_value"}')

      Facter::Util::GCE.add_gce_facts(:force => true)

      Facter.fact(:gce_some_key_name).
        value.should == "some_key_value"
    end

  end
end
