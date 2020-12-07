# frozen_string_literal: true

describe Facter::Resolvers::Ec2 do
  subject(:ec2) { Facter::Resolvers::Ec2 }

  let(:uri) { 'http://169.254.169.254/latest/meta-data/' }
  let(:userdata_uri) { 'http://169.254.169.254/latest/user-data/' }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    allow(Facter::Util::Resolvers::Http).to receive(:get_request).with(uri, {}, { session: 5 }).and_return(output)
    allow(Facter::Util::Resolvers::Http).to receive(:get_request).with(userdata_uri, {}, { session: 5 }).and_return('')
    ec2.instance_variable_set(:@log, log_spy)
  end

  after do
    ec2.invalidate_cache
  end

  context 'when no exception is thrown' do
    let(:output) { "security-credentials/\nami-id" }
    let(:ami_uri) { 'http://169.254.169.254/latest/meta-data/ami-id' }
    let(:ami_id) { 'some_id_123' }

    before do
      allow(Facter::Util::Resolvers::Http).to receive(:get_request)
        .with(ami_uri, {}, { session: 5 }).and_return(ami_id)
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

    it 'returns empty ec2 metadata' do
      expect(ec2.resolve(:metadata)).to eq({})
    end

    it 'returns empty ec2 userdata' do
      expect(ec2.resolve(:userdata)).to eq('')
    end
  end

  context 'when env vars set' do
    before do
      ENV['FACTER_ec2_metadata'] = 'generic_metadata'
      ENV['FACTER_ec2_userdata'] = 'generic_userdata'
    end

    after do
      ENV['FACTER_ec2_metadata'] = nil
      ENV['FACTER_ec2_userdata'] = nil
    end

    it 'returns ec2 metadata' do
      expect(ec2.resolve(:metadata)).to eq('generic_metadata')
    end

    it 'returns ec2 userdata' do
      expect(ec2.resolve(:userdata)).to eq('generic_userdata')
    end
  end
end
