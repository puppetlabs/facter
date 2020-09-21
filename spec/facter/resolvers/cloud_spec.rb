# frozen_string_literal: true

describe Facter::Resolvers::Cloud do
  subject(:cloud_resolver) { Facter::Resolvers::Cloud }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    cloud_resolver.instance_variable_set(:@log, log_spy)
    allow(File).to receive(:readable?)
    allow(File).to receive(:directory?)
    allow(Dir).to receive(:entries)
  end

  after do
    cloud_resolver.invalidate_cache
  end

  context 'when lease files are not found' do
    before do
      allow(File).to receive(:readable?).with('/var/lib/dhcp').and_return(true)
      allow(File).to receive(:directory?).with('/var/lib/dhcp').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/dhcp').and_return('.')
    end

    it 'returns nil' do
      expect(cloud_resolver.resolve(:cloud_provider)).to be_nil
    end
  end

  context 'when lease file is found and contains option 245' do
    let(:content) { load_fixture('dhclient_rhel_lease_8').read }

    before do
      allow(File).to receive(:readable?).with('/var/lib/dhcp').and_return(true)
      allow(File).to receive(:directory?).with('/var/lib/dhcp').and_return(true)
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('/var/lib/dhcp/dhclient.rhel.lease.8')
        .and_return(content)
      allow(Dir).to receive(:entries).with('/var/lib/dhcp').and_return(['.', 'dhclient.rhel.lease.8'])
    end

    it 'returns azure' do
      expect(cloud_resolver.resolve(:cloud_provider)).to eq('azure')
    end
  end

  context 'when lease file is found without option 245' do
    let(:content) { load_fixture('dhcp_lease').read }

    before do
      allow(File).to receive(:readable?).with('/var/lib/dhcp').and_return(true)
      allow(File).to receive(:directory?).with('/var/lib/dhcp').and_return(true)
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('/var/lib/dhcp/dhclient.rhel.lease.8')
        .and_return(content)
      allow(Dir).to receive(:entries).with('/var/lib/dhcp').and_return(['.', 'dhclient.rhel.lease.8'])
    end

    it 'returns nil' do
      expect(cloud_resolver.resolve(:cloud_provider)).to be_nil
    end
  end

  context 'when lease file exists but not readable' do
    let(:content) { '' }

    before do
      allow(File).to receive(:readable?).with('/var/lib/dhcp').and_return(true)
      allow(File).to receive(:directory?).with('/var/lib/dhcp').and_return(true)
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('/var/lib/dhcp/dhclient.rhel.lease.8')
        .and_return([])
      allow(Dir).to receive(:entries).with('/var/lib/dhcp').and_return(['.', 'dhclient.rhel.lease.8'])
    end

    it 'returns nil' do
      expect(cloud_resolver.resolve(:cloud_provider)).to be_nil
    end
  end

  context 'when we do not have read permissions for /var/lib/dhcp ' do
    let(:content) { '' }

    before do
      allow(File).to receive(:readable?).with('/var/lib/dhcp').and_return(false)
      allow(File).to receive(:directory?).with('/var/lib/dhcp').and_return(true)
    end

    it 'returns nil' do
      expect(cloud_resolver.resolve(:cloud_provider)).to be_nil
    end
  end
end
