# frozen_string_literal: true

describe Facter::Resolvers::NetworkingLinux do
  describe '#resolve' do
    before do
      allow(Open3).to receive(:capture2)
        .with('ip -o address')
        .and_return(load_fixture('ip_o_address_linux'))
      allow(Open3).to receive(:capture2)
        .with('ip route get 1')
        .and_return(load_fixture('ip_route__get_1_linux'))
      allow(Open3).to receive(:capture2)
        .with('ip address')
        .and_return(load_fixture('ip_address_linux'))
    end

    let(:subject) { Facter::Resolvers::NetworkingLinux }

    context 'ip' do
      it 'returns the default ip' do
        expect(subject.resolve(:ip)).to eq('10.16.122.163')
      end
    end

    context 'interfaces' do
      it 'returns all the interfaces' do
        result = {
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

        expect(subject.resolve(:interfaces)).to eq(result)
      end
    end
  end
end
