require 'spec_helper'
require 'facter/gce/metadata'

describe Facter::GCE::Metadata, :if => Facter.json? do

  describe "contacting the metadata server" do
    it "retries the request when a connection error is thrown" do
      subject.stubs(:open).returns(stub(:read => '{"hello": "world"}'))
      seq = sequence('open-uri seq')
      Timeout.expects(:timeout).with(0.05).twice.in_sequence(seq).raises(Timeout::Error)
      Timeout.expects(:timeout).with(0.05).once.in_sequence(seq).yields
      expect(subject.fetch).to eq({'hello' => 'world'})
    end

    it "logs the exception when all retries failed" do
      Timeout.expects(:timeout).with(0.05).times(3).raises(Timeout::Error)
      Facter.expects(:log_exception).with(instance_of(Timeout::Error), instance_of(String))
      expect(subject.fetch).to be_nil
    end
  end

  describe "parsing the metadata response" do
    let(:body) { my_fixture_read('metadata.json') }
    before do
      subject.stubs(:open).returns(stub(:read => body))
    end

    it "transforms hash values with the 'image' key" do
      expect(subject.fetch['instance']['image']).to eq 'centos6'
    end

    it "transforms hash values with the 'machineType' key" do
      expect(subject.fetch['instance']['machineType']).to eq 'n1-standard-1'
    end

    it "transforms hash values with the 'zone' key" do
      expect(subject.fetch['instance']['zone']).to eq 'us-central1-b'
    end

    it "transforms hash values with the 'network' key" do
      expect(subject.fetch['instance']['networkInterfaces'][0]['network']).to eq 'default'
    end

    it "splits up the elements of the 'sshKeys' value into an array" do
      expect(subject.fetch['project']['attributes']['sshKeys'][0]).to match(/justin:ssh-rsa/)
      expect(subject.fetch['project']['attributes']['sshKeys'][1]).to match(/adrien:ssh-rsa/)
    end
  end
end
