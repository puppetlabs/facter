# frozen_string_literal: true

describe Facter::Resolvers::Az do
  subject(:az) { Facter::Resolvers::Az }

  let(:uri) { 'http://169.254.169.254/metadata/instance?api-version=2020-09-01' }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    allow(Facter::Util::Resolvers::Http).to receive(:get_request)
      .with(uri, { Metadata: 'true' }, { session: 5 }, false).and_return(output)
    az.instance_variable_set(:@log, log_spy)
  end

  after do
    az.invalidate_cache
  end

  context 'when no exception is thrown' do
    let(:output) { '{"azEnvironment":"AzurePublicCloud"}' }

    it 'returns az metadata' do
      expect(az.resolve(:metadata)).to eq({ 'azEnvironment' => 'AzurePublicCloud' })
    end
  end

  context "when a proxy is set with ENV['http_proxy']" do
    before do
      stub_const('ENV', { 'http_proxy' => 'http://example.com' })
    end

    let(:output) { '{"azEnvironment":"AzurePublicCloud"}' }

    it 'returns az metadata' do
      expect(az.resolve(:metadata)).to eq({ 'azEnvironment' => 'AzurePublicCloud' })
    end
  end

  context 'when an exception is thrown' do
    let(:output) { '' }

    it 'returns empty az metadata' do
      expect(az.resolve(:metadata)).to eq({})
    end
  end
end
