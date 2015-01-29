require 'spec_helper'
require 'facter/ec2/rest'

shared_examples_for "an ec2 rest querier" do
  describe "determining if the uri is reachable" do
    it "retries if the connection times out" do
      subject.stubs(:open).returns(stub(:read => nil))
      Timeout.expects(:timeout).with(0.2).twice.raises(Timeout::Error).returns(true)
      expect(subject).to be_reachable
    end

    it "retries if the connection is reset" do
      subject.expects(:open).twice.raises(Errno::ECONNREFUSED).returns(StringIO.new("woo"))
      expect(subject).to be_reachable
    end

    it "is false if the given uri returns a 404" do
      subject.expects(:open).with(anything, :proxy => nil).once.raises(OpenURI::HTTPError.new("404 Not Found", StringIO.new("woo")))
      expect(subject).to_not be_reachable
    end

    it "is false if the connection always times out" do
      Timeout.expects(:timeout).with(0.2).times(3).raises(Timeout::Error)
      expect(subject).to_not be_reachable
    end
  end

end

describe Facter::EC2::Metadata do

  subject { described_class.new('http://0.0.0.0/latest/meta-data/') }

  let(:response) { StringIO.new }

  describe "fetching a metadata endpoint" do
    it "splits the body into an array" do
      response.string = my_fixture_read("meta-data/root")
      subject.stubs(:open).with("http://0.0.0.0/latest/meta-data/", {:proxy => nil}).returns response
      output = subject.fetch_endpoint('')

      expect(output).to eq %w[
        ami-id ami-launch-index ami-manifest-path block-device-mapping/ hostname
        instance-action instance-id instance-type kernel-id local-hostname
        local-ipv4 mac metrics/ network/ placement/ profile public-hostname
        public-ipv4 public-keys/ reservation-id
      ]
    end

    it "reformats keys that are array indices" do
      response.string = "0=adrien@grey/"
      subject.stubs(:open).with("http://0.0.0.0/latest/meta-data/public-keys/", {:proxy => nil}).returns response
      output = subject.fetch_endpoint("public-keys/")

      expect(output).to eq %w[0/]
    end

    it "returns nil if the endpoint returns a 404" do
      Facter.expects(:log_exception).never
      subject.stubs(:open).with("http://0.0.0.0/latest/meta-data/public-keys/1/", {:proxy => nil}).raises OpenURI::HTTPError.new("404 Not Found", response)
      output = subject.fetch_endpoint('public-keys/1/')

      expect(output).to be_nil
    end

    it "logs an error if the endpoint raises a non-404 HTTPError" do
      Facter.expects(:log_exception).with(instance_of(OpenURI::HTTPError), anything)

      subject.stubs(:open).with("http://0.0.0.0/latest/meta-data/", {:proxy => nil}).raises OpenURI::HTTPError.new("418 I'm a Teapot", response)
      output = subject.fetch_endpoint("")

      expect(output).to be_nil
    end

    it "logs an error if the endpoint raises a connection error" do
      Facter.expects(:log_exception).with(instance_of(Errno::ECONNREFUSED), anything)

      subject.stubs(:open).with("http://0.0.0.0/latest/meta-data/", {:proxy => nil}).raises Errno::ECONNREFUSED
      output = subject.fetch_endpoint('')

      expect(output).to be_nil
    end
  end

  describe "recursively fetching the EC2 metadata API" do
    it "queries the given endpoint for metadata keys" do
      subject.expects(:fetch_endpoint).with("").returns([])
      subject.fetch
    end

    it "fetches the value for a simple metadata key" do
      subject.expects(:fetch_endpoint).with("").returns(['indexthing'])
      subject.expects(:fetch_endpoint).with("indexthing").returns(['first', 'second'])

      output = subject.fetch
      expect(output).to eq({'indexthing' => ['first', 'second']})
    end

    it "unwraps metadata values that are in single element arrays" do
      subject.expects(:fetch_endpoint).with("").returns(['ami-id'])
      subject.expects(:fetch_endpoint).with("ami-id").returns(['i-12x'])

      output = subject.fetch
      expect(output).to eq({'ami-id' => 'i-12x'})
    end

    it "recursively queries an endpoint if the key ends with '/'" do
      subject.expects(:fetch_endpoint).with("").returns(['metrics/'])
      subject.expects(:fetch_endpoint).with("metrics/").returns(['vhostmd'])
      subject.expects(:fetch_endpoint).with("metrics/vhostmd").returns(['woo'])

      output = subject.fetch
      expect(output).to eq({'metrics' => {'vhostmd' => 'woo'}})
    end
  end

  it 'filters out IAM security credentials' do
    subject.expects(:fetch_endpoint).with('').returns(['iam/'])
    subject.expects(:fetch_endpoint).with('iam/').returns(['foo', 'security-credentials/', 'bar/'])
    subject.expects(:fetch_endpoint).with('iam/foo').returns(['baz'])
    subject.expects(:fetch_endpoint).with('iam/bar/').returns(['baz'])
    subject.expects(:fetch_endpoint).with('iam/bar/baz').returns(['foo'])
    output = subject.fetch
    expect(output).to eq({
      'iam' => {
        'foo' => 'baz',
        'bar' => {
          'baz' => 'foo'
        }
      }
    })
  end

  it_behaves_like "an ec2 rest querier"
end

describe Facter::EC2::Userdata do

  subject { described_class.new('http://0.0.0.0/latest/user-data/') }

  let(:response) { StringIO.new }

  describe "reaching the userdata" do
    it "queries the userdata URI" do
      subject.expects(:open).with('http://0.0.0.0/latest/user-data/').returns(response)
      subject.fetch
    end

    it "returns the result of the query without modification" do
      response.string = "clooouuuuud"
      subject.expects(:open).with('http://0.0.0.0/latest/user-data/').returns(response)
      expect(subject.fetch).to eq  "clooouuuuud"
    end

    it "is nil if the URI returned a 404" do
      subject.expects(:open).with('http://0.0.0.0/latest/user-data/').once.raises(OpenURI::HTTPError.new("404 Not Found", StringIO.new("woo")))
      expect(subject.fetch).to be_nil
    end
  end

  it_behaves_like "an ec2 rest querier"
end
