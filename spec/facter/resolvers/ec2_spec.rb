# frozen_string_literal: true

describe Facter::Resolvers::Ec2 do
  subject(:ec2) { Facter::Resolvers::Ec2 }

  let(:uri) { URI.parse('http://169.254.169.254/latest/meta-data/') }
  let(:userdata_uri) { URI.parse('http://169.254.169.254/latest/user-data/') }
  let(:http_spy) { instance_spy(Net::HTTP) }
  let(:response) { instance_spy(Net::HTTPResponse) }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    ec2.instance_variable_set(:@log, log_spy)
    allow(Net::HTTP).to receive(:new).with(uri.host).and_return(http_spy)
    allow(http_spy).to receive(:get).with(uri.path).and_return(response)
    allow(Net::HTTP).to receive(:new).with(userdata_uri.host).and_return(http_spy)
    allow(http_spy).to receive(:get).with(userdata_uri.path).and_return(response_userdata)
  end

  after do
    ec2.invalidate_cache
  end

  context 'when no exception is thrown' do
    let(:output) { "security-credentials/\nami-id" }
    let(:ami_uri) { URI.parse('http://169.254.169.254/latest/meta-data/ami-id') }
    let(:ami_id) { 'some_id_123' }
    let(:response2) { instance_spy(Net::HTTPResponse) }
    let(:response_userdata) { instance_spy(Net::HTTPResponse) }

    before do
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(output)
      allow(Net::HTTP).to receive(:new).with(ami_uri.host).and_return(http_spy)
      allow(http_spy).to receive(:get).with(ami_uri.path).and_return(response2)
      allow(response2).to receive(:code).and_return(200)
      allow(response2).to receive(:body).and_return(ami_id)

      allow(response_userdata).to receive(:code).and_return(404)
    end

    it 'returns ec2 metadata' do
      expect(ec2.resolve(:metadata)).to eq({ 'ami-id' => 'some_id_123' })
    end

    it 'returns empty ec2 userdata as response code is not 200' do
      expect(ec2.resolve(:userdata)).to eq('')
    end
  end

  context 'when an exception is thrown' do
    let(:output) { 'security-credentials/' }
    let(:response_userdata) { instance_spy(Net::HTTPResponse) }

    before do
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(output)
      allow(http_spy).to receive(:get).with(userdata_uri.path).and_raise(Net::OpenTimeout)
    end

    it 'returns empty ec2 metadata' do
      expect(ec2.resolve(:metadata)).to eq({})
    end

    it 'returns empty ec2 userdata' do
      expect(ec2.resolve(:userdata)).to eq('')
    end

    it 'logs timeout error' do
      ec2.resolve(:userdata)

      expect(log_spy).to have_received(:debug)
        .with('http://169.254.169.254/latest/user-data/ timed out while trying to connect')
    end
  end
end
