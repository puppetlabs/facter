# frozen_string_literal: true

def ifaddr_obj(name, ip, mac, netmask, ipv4_type)
  addr_info = instance_spy(AddrInfo, getnameinfo: [mac], ip_address: ip, ip?: true, ipv4?: ipv4_type)
  netmask = instance_spy(AddrInfo, ip_address: netmask)
  instance_spy(Ifaddr, name: name, addr: addr_info, netmask: netmask)
end

describe Facter::Resolvers::NetworkingLinux do
  subject(:networking_linux) { Facter::Resolvers::NetworkingLinux }

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

  describe '#resolve' do
    before do
      networking_linux.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show', logger: log_spy).and_return(load_fixture('ip_link_show').read)
      allow(Socket).to receive(:getifaddrs).and_return(ifaddrs)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show ens160', logger: log_spy).and_return(load_fixture('ip_link_show_ens160').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show lo', logger: log_spy).and_return(load_fixture('ip_link_show_lo').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip route show', logger: log_spy).and_return(load_fixture('ip_route_show').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip -6 route show', logger: log_spy).and_return(load_fixture('ip_-6_route_show').read)
      allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/1', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/run/systemd/netif/leases/2', nil).and_return(load_fixture('dhcp_lease').read)
      allow(Dir).to receive(:entries).with('/var/lib/dhclient/').and_return(['dhclient.lo.leases', 'dhclient.leases'])
      allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(true)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/var/lib/dhclient/dhclient.lo.leases', nil).and_return(load_fixture('dhclient_lease').read)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/proc/net/route', '').and_return(load_fixture('proc_net_route').read)
    end

    after do
      networking_linux.invalidate_cache
    end

    let(:result) do
      {
        'lo' => {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
          ],
          bindings6: [
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1', scope6: 'host' }
          ],
          dhcp: '10.32.22.9',
          ip: '127.0.0.1',
          ip6: '::1',
          mtu: 65_536,
          netmask: '255.0.0.0',
          netmask6: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
          network: '127.0.0.0',
          network6: '::1',
          scope6: 'host'
        },
        'ens160' => {
          bindings: [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' },
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          bindings6: [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::', scope6: 'link' }
          ],
          dhcp: '10.32.22.10',
          ip: '10.16.119.155',
          ip6: 'fe80::250:56ff:fe9a:8481',
          mac: '00:50:56:9a:61:46',
          mtu: 1500,
          netmask: '255.255.240.0',
          netmask6: 'ffff:ffff:ffff:ffff::',
          network: '10.16.112.0',
          network6: 'fe80::',
          scope6: 'link'
        }
      }
    end

    it 'returns all the interfaces' do
      expect(networking_linux.resolve(:interfaces)).to eq(result)
    end

    it 'returns the primary interface' do
      expect(networking_linux.resolve(:primary_interface)).to eq('ens160')
    end

    context 'when caching' do
      it 'returns from cache' do
        networking_linux.resolve(:interfaces)
        networking_linux.resolve(:interfaces)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip link show ens160', logger: log_spy).once
      end
    end

    context 'when invalidate caching' do
      it 'resolved again the fact' do
        networking_linux.resolve(:interfaces)
        networking_linux.invalidate_cache
        networking_linux.resolve(:interfaces)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip link show ens160', logger: log_spy).twice
      end
    end

    context 'when 127.0.0.1 is first ip' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', '127.0.0.1', '00:50:56:9a:61:46', '255.0.0.0', true),
          ifaddr_obj('ens160', '10.16.127.70', '00:50:56:9a:61:46', '255.255.240.0', true),
          ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', '00:50:56:9a:61:46', 'ffff:ffff:ffff:ffff::', false)
        ]
      end

      let(:result_with_127_first) do
        {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' },
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          bindings6: [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::', scope6: 'link' }
          ],
          dhcp: '10.32.22.10',
          ip: '10.16.127.70',
          ip6: 'fe80::250:56ff:fe9a:8481',
          mac: '00:50:56:9a:61:46',
          mtu: 1500,
          netmask: '255.255.240.0',
          netmask6: 'ffff:ffff:ffff:ffff::',
          network: '10.16.112.0',
          network6: 'fe80::',
          scope6: 'link'
        }
      end

      it 'resolves interface ens160' do
        expect(networking_linux.resolve(:interfaces)['ens160']).to eq(result_with_127_first)
      end
    end

    context 'when dhcp is not available on the os' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/1', nil).and_return(nil)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/2', nil).and_return(nil)

        allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp3/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/NetworkManager/').and_return(true)
        allow(Dir).to receive(:entries).with('/var/lib/NetworkManager/').and_return(['internal.ens160.lease'])
        allow(File).to receive(:readable?).with('/var/db/').and_return(false)

        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/var/lib/NetworkManager/internal.ens160.lease', nil).and_return('some_output')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U lo', logger: log_spy).and_return('dhcpcd: command unknown')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U ens160', logger: log_spy).and_return('dhcpcd: command unknown')
      end

      it 'does not add dhcp to lo interface' do
        result = networking_linux.resolve(:interfaces)

        expect(result['lo'][:dhcp]).to be_nil
      end

      it 'does not add dhcp to ens160 interface' do
        result = networking_linux.resolve(:interfaces)

        expect(result['ens160'][:dhcp]).to be_nil
      end
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

        allow(File).to receive(:readable?).with(anything).and_return(false)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U lo', logger: log_spy).and_return('dhcpcd: command unknown')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U ens160', logger: log_spy).and_return('dhcpcd: command unknown')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U eth2', logger: log_spy).and_return('dhcpcd: command unknown')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U eth3', logger: log_spy).and_return('dhcpcd: command unknown')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U bond0', logger: log_spy).and_return('dhcpcd: command unknown')
      end

      it 'resolves the eth2 interface' do
        expected = {
          bindings: [
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          ip: '10.16.127.70',
          mac: '08:00:27:29:dc:a5',
          netmask: '255.255.240.0',
          network: '10.16.112.0'
        }
        expect(networking_linux.resolve(:interfaces)['eth2']).to eq(expected)
      end

      it 'uses the mac from /proc/net/bonding/bond0 for eth3' do
        result = networking_linux.resolve(:interfaces)

        expect(result['eth3'][:mac]).to eq('08:00:27:d5:44:7e')
      end

      it 'resolves bond0 interface' do
        expected = {
          bindings: [
            { address: '11.0.0.3', netmask: '255.255.0.0', network: '11.0.0.0' }
          ],
          ip: '11.0.0.3',
          mac: '08:00:27:29:dc:a5',
          netmask: '255.255.0.0',
          network: '11.0.0.0'
        }
        expect(networking_linux.resolve(:interfaces)['bond0']).to eq(expected)
      end
    end

    context 'when ip route show finds an IP, Socket lib did not retrieve' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', '00:50:56:9a:61:46', 'ffff:ffff:ffff:ffff::', false),
          ifaddr_obj('ens192', '10.16.119.155', '00:50:56:9a:61:46', '255.255.240.0', true)
        ]
      end

      before do
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip link show ens192', logger: log_spy).and_return(load_fixture('ip_link_show_ens160').read)
        allow(File).to receive(:readable?).with(anything).and_return(false)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U ens192', logger: log_spy).and_return('dhcpcd: command unknown')
      end

      it 'adds it to the bindings list' do
        expected = {
          bindings: [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' },
            { address: '10.16.125.217' }
          ],
          ip: '10.16.119.155',
          mac: '00:50:56:9a:61:46',
          netmask: '255.255.240.0',
          network: '10.16.112.0'
        }

        expect(networking_linux.resolve(:interfaces)['ens192']).to eq(expected)
      end
    end

    context 'when Ifaddr.addr throws an error' do
      before do
        allow(ifaddrs[4]).to receive(:addr).and_raise(SocketError)
      end

      it 'does not solve ens160 ipv6 binding' do
        expect(networking_linux.resolve(:interfaces)['ens160']).not_to have_key(:bindings6)
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
        expect(networking_linux.resolve(:interfaces)['lo']).not_to have_key(:bindings)
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

        expect(networking_linux.resolve(:interfaces)['ens160'][:bindings]).to eq(expected)
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
          bindings: [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          dhcp: '10.32.22.10',
          ip: '10.16.119.155',
          mtu: 1500,
          netmask: '255.255.240.0',
          network: '10.16.112.0'
        }

        expect(networking_linux.resolve(:interfaces)['ens160']).to eq(expected)
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
                allow(inspect_sockaddr_obj).to receive(:[]).with(/hwaddr=([\h:]+)/, 1).and_raise(SocketError)
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
          bindings6: [
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff::', network: '::', scope6: 'host' }
          ],
          dhcp: '10.32.22.10',
          ip6: '::1',
          mtu: 1500,
          netmask6: 'ffff:ffff:ffff:ffff::',
          network6: '::',
          scope6: 'host'
        }

        expect(networking_linux.resolve(:interfaces)['ens160']).to eq(expected)
      end
    end

    context 'when Ifaddr.addr.getnameinfo returns ip instead of mac' do
      let(:ifaddrs) do
        [
          ifaddr_obj('ens160', 'fe80::250:56ff:fe9a:8481', 'fe80::250:56ff:fe9a:8481', 'ffff:ffff:ffff:ffff::', false)
        ]
      end

      it 'does not resolve mac' do
        expect(networking_linux.resolve(:interfaces)['ens160']).not_to have_key(:mac)
      end
    end

    context 'when Socket.getifaddrs throws SocketError' do
      before do
        allow(Socket).to receive(:getifaddrs).and_raise(SocketError)
      end

      it 'raises SocketError' do
        expect { networking_linux.resolve(:interfaces) }.to raise_error(SocketError)
      end
    end

    context 'when primary interface can not be read from /proc/net/route' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/proc/net/route', '').and_return('')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip route show default', logger: log_spy).and_return(load_fixture('ip_route_show_default').read)
      end

      it 'returns primary interface' do
        expect(networking_linux.resolve(:primary_interface)).to eq('ens160')
      end
    end

    context 'when primary interface can not be read' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/proc/net/route', '').and_return('')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip route show default', logger: log_spy).and_return(nil)
      end

      it 'returns primary interface as the first not ignored ip' do
        expect(networking_linux.resolve(:primary_interface)).to eq('ens160')
      end
    end
  end
end
