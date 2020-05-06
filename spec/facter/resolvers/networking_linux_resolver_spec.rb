# frozen_string_literal: true

describe Facter::Resolvers::NetworkingLinux do
  subject(:networking_linux) { Facter::Resolvers::NetworkingLinux }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#resolve' do
    before do
      networking_linux.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip -o address', logger: log_spy)
        .and_return(load_fixture('ip_o_address_linux').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip route get 1', logger: log_spy)
        .and_return(load_fixture('ip_route_get_1_linux').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show ens160', logger: log_spy)
        .and_return(load_fixture('ip_address_linux').read)
    end

    after do
      networking_linux.invalidate_cache
    end

    let(:result) do
      {
        'lo' => {
          'bindings' =>
                [
                  { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
                ],
          'bindings6' =>
                [
                  { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' }
                ]
        },
        'ens160' => {
          'bindings' => [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' },
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          'bindings6' => [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }
          ]
        }
      }
    end
    let(:macaddress) { '00:50:56:9a:ec:fb' }

    it 'returns the default ip' do
      expect(networking_linux.resolve(:ip)).to eq('10.16.122.163')
    end

    it 'returns all the interfaces' do
      expect(networking_linux.resolve(:interfaces)).to eq(result)
    end

    it 'return macaddress' do
      expect(networking_linux.resolve(:macaddress)).to eq(macaddress)
    end

    context 'when caching' do
      it 'returns from cache' do
        networking_linux.resolve(:ip)
        networking_linux.resolve(:ip)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip route get 1', logger: log_spy).once
      end
    end

    context 'when invalidate caching' do
      it 'resolved again the fact' do
        networking_linux.resolve(:ip)
        networking_linux.invalidate_cache
        networking_linux.resolve(:ip)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip route get 1', logger: log_spy).twice
      end
    end
  end
end
