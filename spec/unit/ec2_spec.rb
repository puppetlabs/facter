require 'spec_helper'
require 'facter/ec2/rest'

describe "ec2_metadata" do
  let(:querier) { stub('EC2 metadata querier') }

  before do
    Facter::EC2::Metadata.stubs(:new).returns querier

    # Prevent flattened facts from forcing evaluation of the ec2 metadata fact
    Facter.stubs(:value).with(:ec2_metadata)
    Facter.collection.internal_loader.load(:ec2)
    Facter.unstub(:value)
  end

  subject { Facter.fact(:ec2_metadata).resolution(:rest) }

  it "is unsuitable if the virtual fact is not xen,xenu or kvm" do
    querier.stubs(:reachable?).returns false
    Facter.fact(:virtual).stubs(:value).returns("Not kvm","Not xen","Not xenu")
    expect(subject).to_not be_suitable
  end

  it "is unsuitable if ec2 endpoint is not reachable" do
    Facter.fact(:virtual).stubs(:value).returns("xen","kvm")
    querier.stubs(:reachable?).returns false
    expect(subject).to_not be_suitable
  end

  describe "when the ec2 endpoint is reachable" do
    before do
      querier.stubs(:reachable?).returns true
    end

    it "is suitable if the virtual fact is xen" do
      Facter.fact(:virtual).stubs(:value).returns "xen"
      subject.suitable?

      expect(subject).to be_suitable
    end

    it "is suitable if the virtual fact is kvm" do
      Facter.fact(:virtual).stubs(:value).returns "kvm"
      subject.suitable?

      expect(subject).to be_suitable
    end

    it "is suitable if the virtual fact is xenu" do
      Facter.fact(:virtual).stubs(:value).returns "xenu"
      expect(subject).to be_suitable
    end
  end

  it "resolves the value by recursively querying the rest endpoint" do
    querier.expects(:fetch).returns({"hello" => "world"})
    expect(subject.value).to eq({"hello" => "world"})
  end
end

describe "ec2_userdata" do
  let(:querier) { stub('EC2 metadata querier') }

  before do
    Facter::EC2::Userdata.stubs(:new).returns querier

    # Prevent flattened facts from forcing evaluation of the ec2 metadata fact
    Facter.stubs(:value).with(:ec2_metadata)
    Facter.collection.internal_loader.load(:ec2)
    Facter.unstub(:value)
  end

  subject { Facter.fact(:ec2_userdata).resolution(:rest) }

  it "is unsuitable if the virtual fact is not xen,xenu or kvm" do
    querier.stubs(:reachable?).returns(true)
    Facter.fact(:virtual).stubs(:value).returns("Not kvm","Not xen","Not xenu")
    expect(subject).to_not be_suitable
  end

  it "is unsuitable if ec2 endpoint is not reachable" do
    Facter.fact(:virtual).stubs(:value).returns("xen","kvm")
    querier.stubs(:reachable?).returns false
    expect(subject).to_not be_suitable
  end

  describe "when the ec2 endpoint is reachable" do
    before do
      querier.stubs(:reachable?).returns true
    end

    it "is suitable if the virtual fact is xen" do
      Facter.fact(:virtual).stubs(:value).returns "xen"
      expect(subject).to be_suitable
    end

    it "is suitable if the virtual fact is kvm" do
      Facter.fact(:virtual).stubs(:value).returns "kvm"
      expect(subject).to be_suitable
    end

    it "is suitable if the virtual fact is xenu" do
      Facter.fact(:virtual).stubs(:value).returns "xenu"
      expect(subject).to be_suitable
    end
  end

  it "resolves the value by fetching the rest endpoint" do
    querier.expects(:fetch).returns "user data!"
    expect(subject.value).to eq "user data!"
  end
end

describe "flattened versions of ec2 facts" do
  # These facts are tricky to test because they are dynamic facts, and they are
  # generated from a fact that is defined in the same file. In order to pull
  # this off we need to define the ec2_metadata fact ahead of time so that we
  # can stub the value, and then manually load the correct files.

  it "unpacks the ec2_metadata fact" do
    Facter.define_fact(:ec2_metadata).stubs(:value).returns({"hello" => "world"})
    Facter.collection.internal_loader.load(:ec2)

    expect(Facter.value("ec2_hello")).to eq "world"
  end

  it "does not set any flat ec2 facts if the ec2_metadata fact is nil" do
    Facter.define_fact(:ec2_metadata).stubs(:value)
    Facter.define_fact(:ec2_userdata).stubs(:value).returns(nil)

    Facter.collection.internal_loader.load(:ec2)

    all_facts = Facter.collection.to_hash

    ec2_facts = all_facts.keys.select { |k| k =~ /^ec2_/ }
    expect(ec2_facts).to be_empty
  end

end
