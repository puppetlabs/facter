# frozen_string_literal: true

describe Facter::Resolvers::NetworkingLinux do
  subject(:networking_linux) { Facter::Resolvers::NetworkingLinux }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:ip_command) { load_fixture('ip_o_address_linux').read }

  describe '#resolve' do
    before do
      networking_linux.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip -o address', logger: log_spy)
        .and_return(ip_command)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip route get 1', logger: log_spy)
        .and_return(load_fixture('ip_route_get_1_linux').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show ens160', logger: log_spy)
        .and_return(load_fixture('ip_address_linux').read)

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/run/systemd/netif/leases/1', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/run/systemd/netif/leases/2', nil).and_return(load_fixture('dhcp_lease').read)

      allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/dhclient/').and_return(['dhclient.lo.leases', 'dhclient.leases'])
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/var/lib/dhclient/dhclient.lo.leases', nil).and_return(load_fixture('dhclient_lease').read)

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/class/net/lo/address', nil).and_return('00:00:00:00:00:00')
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/class/net/lo/mtu', nil).and_return('65536')
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/class/net/ens160/address', nil).and_return('00:50:56:9a:61:46')
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/class/net/ens160/mtu', nil).and_return('1500')
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
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' }
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
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }
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

    let(:result_with_127_first) do
      {
        'lo' => {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
          ],
          bindings6: [
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' }
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
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' },
            { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
          ],
          bindings6: [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }
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
      }
    end

    let(:result_with_peer) do
      {
        'lo' => {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
          ],
          bindings6: [
            { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' }
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
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' },
            { address: '10.141.0.2', netmask: '255.255.255.255', network: '10.141.0.2' }
          ],
          bindings6: [
            { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }
          ],
          dhcp: '10.32.22.10',
          ip: '10.141.0.2',
          ip6: 'fe80::250:56ff:fe9a:8481',
          mac: '00:50:56:9a:61:46',
          mtu: 1500,
          netmask: '255.255.255.255',
          netmask6: 'ffff:ffff:ffff:ffff::',
          network: '10.141.0.2',
          network6: 'fe80::',
          scope6: 'link'
        }
      }
    end
    let(:macaddress) { '00:50:56:9a:ec:fb' }

    it 'returns all the interfaces' do
      expect(networking_linux.resolve(:interfaces)).to eq(result)
    end

    context 'when caching' do
      it 'returns from cache' do
        networking_linux.resolve(:interfaces)
        networking_linux.resolve(:interfaces)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip route get 1', logger: log_spy).once
      end
    end

    context 'when invalidate caching' do
      it 'resolved again the fact' do
        networking_linux.resolve(:interfaces)
        networking_linux.invalidate_cache
        networking_linux.resolve(:interfaces)

        expect(Facter::Core::Execution).to have_received(:execute)
          .with('ip route get 1', logger: log_spy).twice
      end
    end

    context 'when 127.0.0.1 is first ip' do
      let(:ip_command) { load_fixture('ip_o_address_linux_with_127_first').read }

      it 'is ignored and the next ip is used' do
        expect(networking_linux.resolve(:interfaces)).to eq(result_with_127_first)
      end
    end

    context 'when there is a peer ip address' do
      let(:ip_command) { load_fixture('ip_o_address_with_peer').read }

      it 'resolves all bindings' do
        expect(networking_linux.resolve(:interfaces)).to eq(result_with_peer)
      end
    end

    context 'when dhcp is not available on the os' do
      let(:result_with_nil_dhcp) do
        {
          'lo' => {
            bindings: [
              { address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }
            ],
            bindings6: [
              { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' }
            ],
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
              { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }
            ],
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

      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/run/systemd/netif/leases/1', nil).and_return(nil)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/run/systemd/netif/leases/2', nil).and_return(nil)

        allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp3/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/NetworkManager/').and_return(true)
        allow(Dir).to receive(:entries).with('/var/lib/NetworkManager/').and_return(['internal.ens160.lease'])
        allow(File).to receive(:readable?).with('/var/db/').and_return(false)

        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/var/lib/NetworkManager/internal.ens160.lease', nil)
          .and_return('some_output')
      end

      it 'is ignored and the next ip is used' do
        expect(networking_linux.resolve(:interfaces)).to eq(result_with_nil_dhcp)
      end
    end
  end
end
