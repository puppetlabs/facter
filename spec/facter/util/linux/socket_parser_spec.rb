# frozen_string_literal: true

def ifaddr_obj(name, ip, mac, netmask, ipv4_type)
  addr_info = instance_spy(AddrInfo, getnameinfo: [mac], inspect_sockaddr: "hwaddr=#{mac}",
                                     ip_address: ip, ip?: true, ipv4?: ipv4_type)
  netmask = instance_spy(AddrInfo, ip_address: netmask)
  instance_spy(Ifaddr, name: name, addr: addr_info, netmask: netmask)
end

describe Facter::Util::Linux::SocketParser do
  subject(:socket_parser) { Facter::Util::Linux::SocketParser }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:ifaddrs) do
    [
      ifaddr_obj('lo', '127.0.0.1', '00:00:00:00:00:00', '255.0.0.0', true),
      ifaddr_obj('lo', '::1', '00:00:00:00:00:00', 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', false),
      ifaddr_obj('ens160', '10.16.119.155', '00:50:56:9a:61:46', '255.255.240.0', true),
      ifaddr_obj('ens160', '10.16.127.70', '00:50:56:9a:61:46', '255.255.240.0', true),
      ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', '00:50:56:9a:61:46', 'ffff:ffff:ffff:ffff::', false)
    ]
  end

  describe '#retrieve_interfaces' do
    before do
      allow(Socket).to receive(:getifaddrs).and_return(ifaddrs)
      allow(Socket).to receive(:const_defined?).with(:PF_LINK).and_return(true)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show ens160', logger: log_spy).and_return(load_fixture('ip_link_show_ens160').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show lo', logger: log_spy).and_return(load_fixture('ip_link_show_lo').read)
    end

    let(:result) do
      {
        'lo' => {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
          ],
          bindings6: [
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1', scope6: 'host' }
          ]
        },
        'ens160' => {
          bindings: [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' },
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          bindings6: [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::', scope6: 'link' }
          ],
          mac: '00:50:56:9a:61:46'
        }
      }
    end

    it 'returns all the interfaces' do
      expect(socket_parser.retrieve_interfaces(log_spy)).to eq(result)
    end

    context 'when bonded interfaces are present' do
      let(:ifaddrs) do
        [
          ifaddr_obj('lo', '127.0.0.1', '00:00:00:00:00:00', '255.0.0.0', true),
          ifaddr_obj('lo', '::1', '00:00:00:00:00:00', 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', false),
          ifaddr_obj('ens160', '10.16.119.155', '00:50:56:9a:61:46', '255.255.240.0', true),
          ifaddr_obj('eth2', '10.16.127.70', '08:00:27:29:dc:a5', '255.255.240.0', true),
          ifaddr_obj('eth3', '11.11.0.1', '08:00:27:29:dc:a5', '255.255.0.0', true),
          ifaddr_obj('bond0', '11.0.0.3', '08:00:27:29:dc:a5', '255.255.0.0', true)
        ]
      end

      before do
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show ens160', logger: log_spy).and_return(load_fixture('ip_link_show_ens160').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show lo', logger: log_spy).and_return(load_fixture('ip_link_show_lo').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show eth2', logger: log_spy).and_return(load_fixture('ip_link_show_eth2_bonded').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show eth3', logger: log_spy).and_return(load_fixture('ip_link_show_eth3_bonded').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show bond0', logger: log_spy).and_return(load_fixture('ip_link_show_bond0_bonded').read)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/proc/net/bonding/bond0', nil).and_return(load_fixture('bond_interface_data').read)
      end

      it 'retrieves eth2 interface' do
        expected = {
          bindings: [
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          mac: '08:00:27:29:dc:a5'
        }

        expect(socket_parser.retrieve_interfaces(log_spy)['eth2']).to eq(expected)
      end

      it 'uses the mac from /proc/net/bonding/bond0 for eth3' do
        result = socket_parser.retrieve_interfaces(log_spy)

        expect(result['eth3'][:mac]).to eq('08:00:27:d5:44:7e')
      end

      it 'retrieves bond0 interface' do
        expected = {
          bindings: [
            { address: '11.0.0.3', netmask: '255.255.0.0', network: '11.0.0.0' }
          ],
          mac: '08:00:27:29:dc:a5'
        }

        expect(socket_parser.retrieve_interfaces(log_spy)['bond0']).to eq(expected)
      end
    end

    context 'when the defined constant is Socket::PF_PACKET, not Socket::PF_LINK' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', '10.16.119.155', '00:50:56:9a:61:46', '255.255.240.0', true)
        ]
      end

      before do
        allow(Socket).to receive(:const_defined?).with(:PF_LINK).and_return(false)
        allow(Socket).to receive(:const_defined?).with(:PF_PACKET).and_return(true)
      end

      it 'manages to retrieve mac for ens160' do
        expect(socket_parser.retrieve_interfaces(log_spy)['ens160'][:mac]).to eq('00:50:56:9a:61:46')
      end
    end

    context 'when Ifaddr.addr throws an error' do
      before do
        allow(ifaddrs[4]).to receive(:addr).and_raise(SocketError)
      end

      it 'does not solve ens160 ipv6 binding' do
        expect(socket_parser.retrieve_interfaces(log_spy)['ens160']).not_to have_key(:bindings6)
      end

      it 'resolves the mac and ipv4 binding for ens160' do
        expect(socket_parser.retrieve_interfaces(log_spy)['ens160'].keys).to match_array(%i[mac bindings])
      end
    end

    context 'when Ifaddr.addr.ip_address throws SocketError' do
      before do
        allow(ifaddrs[0]).to receive(:addr) do
          double.tap do |addr_returned_object|
            allow(addr_returned_object).to receive(:getnameinfo).and_return(['00:00:00:00:00:00'])
            allow(addr_returned_object).to receive(:ip?).and_return(true)
            allow(addr_returned_object).to receive(:ip_address).and_raise(SocketError)
          end
        end
      end

      it 'does not solve lo ipv4 binding' do
        expect(socket_parser.retrieve_interfaces(log_spy)['lo']).not_to have_key(:bindings)
      end

      it 'resolves the mac and ipv6 binding for lo' do
        expect(socket_parser.retrieve_interfaces(log_spy)['lo'].keys).to match_array([:bindings6])
      end
    end

    context 'when Ifaddr.netmask.ip_address throws SocketError' do
      before do
        allow(ifaddrs[2]).to receive(:netmask) do
          double.tap do |addr_returned_object|
            allow(addr_returned_object).to receive(:ip_address).and_raise(SocketError)
          end
        end
      end

      it 'does not solve ens160 first ipv4 binding' do
        expected = [{ address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }]

        expect(socket_parser.retrieve_interfaces(log_spy)['ens160'][:bindings]).to eq(expected)
      end
    end

    context 'when Ifaddr.addr.getnameinfo throws SocketError' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', '10.16.119.155', '00:50:56:9a:61:46', '255.255.240.0', true)

        ]
      end

      before do
        allow(Socket).to receive(:const_defined?).with(:PF_LINK).and_return(true)
        allow(ifaddrs[0]).to receive(:addr) do
          double.tap do |addr_returned_object|
            allow(addr_returned_object).to receive(:getnameinfo).and_raise(SocketError)
            allow(addr_returned_object).to receive(:ip?).and_return(true)
            allow(addr_returned_object).to receive(:ip_address).and_return('10.16.119.155')
            allow(addr_returned_object).to receive(:ipv4?).and_return(true)
          end
        end
      end

      it 'does not retrieve mac for ens160' do
        expected = {
          'ens160' => {
            bindings: [
              { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' }
            ]
          }
        }

        expect(socket_parser.retrieve_interfaces(log_spy)).to eq(expected)
      end
    end

    context 'when Ifaddr.addr.inspect_sockaddr throws SocketError' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', '00:50:56:9a:61:46', 'ffff:ffff:ffff:ffff::', false)
        ]
      end

      before do
        allow(Socket).to receive(:const_defined?).with(:PF_LINK).and_return(false)
        allow(Socket).to receive(:const_defined?).with(:PF_PACKET).and_return(true)
        allow(ifaddrs[0]).to receive(:addr) do
          double.tap do |addr_returned_object|
            allow(addr_returned_object).to receive(:inspect_sockaddr) do
              double.tap do |inspect_sockaddr_obj|
                allow(inspect_sockaddr_obj).to receive(:nil?).and_return(false)
                allow(inspect_sockaddr_obj).to receive(:match).with(/hwaddr=([\h:]+)/).and_raise(SocketError)
              end
            end
            allow(addr_returned_object).to receive(:ip?).and_return(true)
            allow(addr_returned_object).to receive(:ip_address).and_return('::1')
            allow(addr_returned_object).to receive(:ipv4?).and_return(false)
          end
        end
      end

      it 'does not retrieve mac for ens160' do
        expected = {
          'ens160' => {
            bindings6: [
              { address: '::1', netmask: 'ffff:ffff:ffff:ffff::', network: '::', scope6: 'host' }
            ]
          }
        }

        expect(socket_parser.retrieve_interfaces(log_spy)).to eq(expected)
      end
    end

    context 'when Ifaddr.addr.getnameinfo returns ip instead of mac' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', 'fe80::250:56ff:fe9a:8481', 'ffff:ffff:ffff:ffff::', false)
        ]
      end

      it 'does not retrieve_interfaces mac' do
        expect(socket_parser.retrieve_interfaces(log_spy)['ens160']).not_to have_key(:mac)
      end
    end

    context 'when Socket.getifaddrs throws SocketError' do
      before do
        allow(Socket).to receive(:getifaddrs).and_raise(SocketError)
      end

      it 'raises SocketError' do
        expect { socket_parser.retrieve_interfaces(log_spy) }.to raise_error(SocketError)
      end
    end
  end
end
