# frozen_string_literal: true

describe Facter::Resolvers::Aix::Networking do
  subject(:networking_resolver) { Facter::Resolvers::Aix::Networking }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    networking_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('netstat -rn', logger: log_spy)
      .and_return(netstat_rn)

    allow(Facter::Core::Execution).to receive(:execute)
      .with('netstat -in', logger: log_spy)
      .and_return(netstat_in)
  end

  after do
    networking_resolver.invalidate_cache
  end

  context 'when netstat command exists' do
    let(:netstat_in) { load_fixture('netstat_in').read }
    let(:netstat_rn) { load_fixture('netstat_rn').read }
    let(:interfaces) do
      {
        'en0' => { bindings: [{ address: '10.32.77.40', netmask: '255.255.255.0', network: '10.32.77.0' }],
                   ip: '10.32.77.40', mac: '0a:c6:24:39:41:03', mtu: 1500, netmask: '255.255.255.0',
                   network: '10.32.77.0' },
        'lo0' => { bindings: [{ address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }],
                   bindings6: [{ address: '::1', netmask: '::', network: '::', scope6: 'host' }], ip: '127.0.0.1',
                   ip6: '::1', mtu: 16_896, netmask: '255.0.0.0', netmask6: '::', network: '127.0.0.0',
                   network6: '::', scope6: 'host' }
      }
    end
    let(:primary) { 'en0' }

    it 'returns primary interface' do
      expect(networking_resolver.resolve(:primary_interface)).to eq(primary)
    end

    it 'returns ipv4 for primary interface' do
      expect(networking_resolver.resolve(:ip)).to eq(interfaces[primary][:ip])
    end

    it 'returns interfaces fact' do
      expect(networking_resolver.resolve(:interfaces)).to eq(interfaces)
    end

    it 'returns mtu fact' do
      expect(networking_resolver.resolve(:mtu)).to eq(interfaces[primary][:mtu])
    end
  end

  context 'when netstat command does not exist' do
    let(:netstat_in) { '' }
    let(:netstat_rn) { '' }

    it 'returns primary interface' do
      expect(networking_resolver.resolve(:primary_interface)).to be_nil
    end

    it 'returns interfaces fact' do
      expect(networking_resolver.resolve(:interfaces)).to be_an_instance_of(Hash).and contain_exactly
    end

    it 'returns mtu fact' do
      expect(networking_resolver.resolve(:mtu)).to be_nil
    end
  end
end
