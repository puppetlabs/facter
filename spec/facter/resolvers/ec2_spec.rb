# frozen_string_literal: true

describe Facter::Resolvers::Ec2 do
  subject(:ec2) { Facter::Resolvers::Ec2 }

  let(:base_uri) { 'http://169.254.169.254/latest' }
  let(:userdata_uri) { "#{base_uri}/user-data/" }
  let(:metadata_uri) { "#{base_uri}/meta-data/" }
  let(:token_uri) { "#{base_uri}/api/token" }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    Facter::Util::Resolvers::Http.instance_variable_set(:@log, log_spy)
    allow(Socket).to receive(:tcp) if Gem.win_platform?
  end

  after do
    ec2.invalidate_cache
    Facter::Util::Resolvers::AwsToken.reset
    Facter::Util::Resolvers::Http.instance_variable_set(:@log, nil)
  end

  shared_examples_for 'ec2' do
    let(:paths) do
      {
        'meta-data/' => "instance_type\nami_id\nsecurity-groups",
        'meta-data/instance_type' => 'c1.medium',
        'meta-data/ami_id' => 'ami-5d2dc934',
        'meta-data/security-groups' => "group1\ngroup2"
      }
    end

    before do
      stub_request(:get, userdata_uri).with(headers: headers).to_return(status: 200, body: 'userdata')
      paths.each_pair do |path, body|
        stub_request(:get, "#{base_uri}/#{path}").with(headers: headers).to_return(status: 200, body: body)
      end
    end

    context 'with common metadata paths' do
      it 'recursively fetches all the ec2 metadata' do
        expect(ec2.resolve(:metadata)).to match(
          {
            'instance_type' => 'c1.medium',
            'ami_id' => 'ami-5d2dc934',
            'security-groups' => "group1\ngroup2"
          }
        )
      end

      it 'returns userdata' do
        expect(ec2.resolve(:userdata)).to eql('userdata')
      end

      it 'parses ec2 network/ directory as a multi-level hash' do
        network_hash = {
          'network' => {
            'interfaces' => {
              'macs' => {
                '12:34:56:78:9a:bc' => {
                  'accountId' => '41234'
                }
              }
            }
          }
        }
        stub_request(:get, metadata_uri).with(headers: headers).to_return(status: 200, body: 'network/')
        stub_request(:get, "#{metadata_uri}network/")
          .with(headers: headers)
          .to_return(status: 200, body: 'interfaces/')
        stub_request(:get, "#{metadata_uri}network/interfaces/")
          .with(headers: headers)
          .to_return(status: 200, body: 'macs/')
        stub_request(:get, "#{metadata_uri}network/interfaces/macs/")
          .with(headers: headers)
          .to_return(status: 200, body: '12:34:56:78:9a:bc/')
        stub_request(:get, "#{metadata_uri}network/interfaces/macs/12:34:56:78:9a:bc/")
          .with(headers: headers)
          .to_return(status: 200, body: 'accountId')
        stub_request(:get, "#{metadata_uri}network/interfaces/macs/12:34:56:78:9a:bc/accountId")
          .with(headers: headers)
          .to_return(status: 200, body: '41234')

        expect(ec2.resolve(:metadata)).to match(hash_including(network_hash))
      end

      it 'fetches the available data' do
        stub_request(:get, "#{metadata_uri}instance_type").with(headers: headers).to_return(status: 404)

        expect(ec2.resolve(:metadata)).to match(
          {
            'instance_type' => '',
            'ami_id' => 'ami-5d2dc934',
            'security-groups' => "group1\ngroup2"
          }
        )
      end
    end

    context 'when an exception is thrown' do
      before do
        stub_request(:get, userdata_uri).to_raise(StandardError)
        stub_request(:get, metadata_uri).to_raise(StandardError)
      end

      it 'returns empty ec2 metadata' do
        expect(ec2.resolve(:metadata)).to eql({})
      end

      it 'returns empty ec2 userdata' do
        expect(ec2.resolve(:userdata)).to eql('')
      end
    end
  end

  context 'when IMDSv2' do
    before do
      stub_request(:put, token_uri).to_return(status: 200, body: token)
    end

    let(:token) { 'v2_token' }
    let(:headers) { { 'X-aws-ec2-metadata-token' => token } }

    it_behaves_like 'ec2'
  end

  context 'when IMDSv1' do
    before do
      stub_request(:put, token_uri).to_return(status: 404, body: 'Not Found')
    end

    let(:token) { nil }
    let(:headers) { { 'Accept' => '*/*' } }

    it_behaves_like 'ec2'
  end

  it 'does not add headers if token is nil' do
    allow(Facter::Resolvers::Ec2).to receive(:v2_token).and_return(nil)

    stub_request(:get, metadata_uri).with { |request| !request.headers.key?('X-aws-ec2-metadata-token') }
    stub_request(:get, userdata_uri).with { |request| !request.headers.key?('X-aws-ec2-metadata-token') }

    ec2.resolve(:userdata)
  end

  context 'when data received are ASCII-8BIT encoded' do
    let(:headers) { { 'Accept' => '*/*' } }

    it 'converts data received to UTF-8 encoding' do
      allow(Facter::Resolvers::Ec2).to receive(:v2_token).and_return(nil)

      expected_str = "nofail\xCC\xA6\"".strip
      bin_str = "nofail\xCC\xA6\"".strip.force_encoding(Encoding::ASCII_8BIT)
      stub_request(:get, userdata_uri).with(headers: headers).to_return(status: 200, body: bin_str, headers:
        { 'Content-Type' => 'application/octet-stream' })
      stub_request(:get, metadata_uri).with { |request| !request.headers.key?('X-aws-ec2-metadata-token') }

      expect(ec2.resolve(:userdata)).to eql(expected_str)
    end
  end

  context "when a proxy is set with ENV['http_proxy']" do
    before do
      stub_const('ENV', { 'http_proxy' => 'http://example.com' })
      stub_request(:put, token_uri).to_return(status: 200, body: token)
    end

    let(:headers) { { 'Accept' => '*/*' } }
    let(:token) { 'v2_token' }

    it_behaves_like 'ec2'
  end
end
