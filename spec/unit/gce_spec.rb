require 'spec_helper'
require 'facter/gce/metadata'

describe "gce_metadata" do
  let(:querier) { stub('GCE metadata querier') }

  before do
    Facter::GCE::Metadata.stubs(:new).returns querier
    Facter.collection.internal_loader.load(:ec2)
  end

  subject { Facter.fact(:gce).resolution(:rest) }

  it "is unsuitable when the virtual type is not gce" do
    Facter.fact(:virtual).stubs(:value).returns 'kvm'
    expect(subject).to_not be_suitable
  end

  it "is unsuitable when JSON is not available" do
    Facter.stubs(:json?).returns false
    expect(subject).to_not be_suitable
  end

  it "is suitable when both the virtual type is gce and JSON is available" do
    Facter.fact(:virtual).stubs(:value).returns 'gce'
    Facter.stubs(:json?).returns true
    expect(subject).to be_suitable
  end

  it "resolves the fact by querying GCE metadata API" do
    querier.expects(:fetch).returns({'hello' => 'world'})
    expect(subject.value).to eq({'hello' => 'world'})
  end
end
