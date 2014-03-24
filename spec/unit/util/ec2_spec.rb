require 'spec_helper'
require 'facter/util/ec2'

describe Facter::Util::EC2 do
  let(:response) { StringIO.new }

  describe "fetching a uri" do
    it "splits the body into an array" do
      response.string = my_fixture_read("meta-data/root")
      described_class.stubs(:open).with("http://169.254.169.254/latest/meta-data/").returns response
      output = described_class.fetch("http://169.254.169.254/latest/meta-data/")

      expect(output).to eq %w[
        ami-id ami-launch-index ami-manifest-path block-device-mapping/ hostname
        instance-action instance-id instance-type kernel-id local-hostname
        local-ipv4 mac metrics/ network/ placement/ profile public-hostname
        public-ipv4 public-keys/ reservation-id
      ]
    end

    it "reformats keys that are array indices" do
      response.string = "0=adrien@grey/"
      described_class.stubs(:open).with("http://169.254.169.254/latest/meta-data/public-keys/").returns response
      output = described_class.fetch("http://169.254.169.254/latest/meta-data/public-keys/")

      expect(output).to eq %w[0/]
    end

    it "returns nil if the endpoint returns a 404" do
      described_class.stubs(:open).with("http://169.254.169.254/latest/meta-data/public-keys/1/").raises OpenURI::HTTPError.new("404 Not Found", response)
      output = described_class.fetch("http://169.254.169.254/latest/meta-data/public-keys/1/")

      expect(output).to be_nil
    end

    it "logs an error if the endpoint raises a non-404 HTTPError" do
      Facter.expects(:log_exception).with(instance_of(OpenURI::HTTPError), anything)

      described_class.stubs(:open).with("http://169.254.169.254/latest/meta-data/").raises OpenURI::HTTPError.new("418 I'm a Teapot", response)
      output = described_class.fetch("http://169.254.169.254/latest/meta-data/")

      expect(output).to be_nil
    end

    it "logs an error if the endpoint raises a connection error" do
      Facter.expects(:log_exception).with(instance_of(Errno::ECONNREFUSED), anything)

      described_class.stubs(:open).with("http://169.254.169.254/latest/meta-data/").raises Errno::ECONNREFUSED
      output = described_class.fetch("http://169.254.169.254/latest/meta-data/")

      expect(output).to be_nil
    end
  end

  describe "recursively fetching the EC2 metadata API" do
    it "queries the given endpoint for metadata keys" do
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/").returns([])
      described_class.recursive_fetch("http://169.254.169.254/latest/meta-data/")
    end

    it "fetches the value for a simple metadata key" do
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/").returns(['indexthing'])
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/indexthing").returns(['first', 'second'])

      output = described_class.recursive_fetch("http://169.254.169.254/latest/meta-data/")
      expect(output).to eq({'indexthing' => ['first', 'second']})
    end

    it "unwraps metadata values that are in single element arrays" do
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/").returns(['ami-id'])
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/ami-id").returns(['i-12x'])

      output = described_class.recursive_fetch("http://169.254.169.254/latest/meta-data/")
      expect(output).to eq({'ami-id' => 'i-12x'})
    end

    it "recursively queries an endpoint if the key ends with '/'" do
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/").returns(['metrics/'])
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/metrics/").returns(['vhostmd'])
      described_class.expects(:fetch).with("http://169.254.169.254/latest/meta-data/metrics/vhostmd").returns(['woo'])

      output = described_class.recursive_fetch("http://169.254.169.254/latest/meta-data/")
      expect(output).to eq({'metrics' => {'vhostmd' => 'woo'}})
    end
  end

  describe "determining if a uri is reachable" do
    it "retries if the connection times out" do
      described_class.stubs(:fetch)
      Timeout.expects(:timeout).with(0.2).twice.raises(Timeout::Error).returns(true)
      expect(described_class.uri_reachable?("http://169.254.169.254/latest/meta-data/")).to be_true
    end

    it "retries if the connection is reset" do
      described_class.expects(:open).with(anything).twice.raises(Errno::ECONNREFUSED).returns(StringIO.new("woo"))
      expect(described_class.uri_reachable?("http://169.254.169.254/latest/meta-data/")).to be_true
    end

    it "is false if the given uri returns a 404" do
      described_class.expects(:open).with(anything).once.raises(OpenURI::HTTPError.new("404 Not Found", StringIO.new("woo")))
      expect(described_class.uri_reachable?("http://169.254.169.254/latest/meta-data/")).to be_false
    end
  end
end
