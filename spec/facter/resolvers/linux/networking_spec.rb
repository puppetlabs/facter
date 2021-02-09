# frozen_string_literal: true

describe Facter::Resolvers::Linux::Networking do
  subject(:networking_linux) { Facter::Resolvers::Linux::Networking }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#resolve' do
    before do
      networking_linux.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('ip link show', logger: log_spy).and_return(load_fixture('ip_link_show').read)
      allow(Facter::Util::Linux::SocketParser).to receive(:retrieve_interfaces)
        .with(log_spy).and_return(socket_interfaces)
      allow(Facter::Util::Linux::Dhcp).to receive(:dhcp).with('lo', '1', log_spy).and_return('10.32.22.9')
      allow(Facter::Util::Linux::Dhcp).to receive(:dhcp).with('ens160', '2', log_spy).and_return('10.32.22.10')
      allow(Facter::Util::Linux::RoutingTable).to receive(:read_routing_table)
        .with(log_spy).and_return([[{ interface: 'ens192', ip: '10.16.125.217' }], []])
      allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_proc_route)
        .and_return('ens160')
    end

    after do
      networking_linux.invalidate_cache
    end

    let(:socket_interfaces) do
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

        expect(Facter::Util::Linux::SocketParser).to have_received(:retrieve_interfaces)
          .with(log_spy).once
      end
    end

    context 'when invalidate caching' do
      it 'resolved again the fact' do
        networking_linux.resolve(:interfaces)
        networking_linux.invalidate_cache
        networking_linux.resolve(:interfaces)

        expect(Facter::Util::Linux::SocketParser).to have_received(:retrieve_interfaces)
          .with(log_spy).twice
      end
    end

    context 'when 127.0.0.1 is first ip' do
      let(:socket_interfaces) do
        {
          'ens160' => {
            bindings: [
              { address: '127.0.0.1', netmask: '255.0.0.0', network: '10.16.112.0' },
              { address: '10.16.127.70', netmask: '255.255.240.0', network: '10.16.112.0' }
            ],
            bindings6: [
              { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::',
                network: 'fe80::', scope6: 'link' }
            ],
            mac: '00:50:56:9a:61:46'
          }
        }
      end

      let(:result_with_127_first) do
        {
          bindings: [
            { address: '127.0.0.1', netmask: '255.0.0.0', network: '10.16.112.0' },
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
        allow(Facter::Util::Linux::Dhcp).to receive(:dhcp).with('lo', '1', log_spy).and_return(nil)
      end

      it 'does not add dhcp to lo interface' do
        result = networking_linux.resolve(:interfaces)

        expect(result['lo'][:dhcp]).to be_nil
      end
    end

    context 'when ip route show finds an IP, Socket lib did not retrieve' do
      before do
        allow(Facter::Util::Linux::RoutingTable).to receive(:read_routing_table)
          .with(log_spy).and_return([[{ interface: 'ens160', ip: '10.16.125.217' }], []])
      end

      let(:socket_interfaces) do
        {
          'ens160' => {
            bindings: [
              { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' }
            ],
            mac: '00:50:56:9a:61:46'
          }
        }
      end

      it 'adds it to the bindings list' do
        expected = {
          bindings: [
            { address: '10.16.119.155', netmask: '255.255.240.0', network: '10.16.112.0' },
            { address: '10.16.125.217' }
          ],
          dhcp: '10.32.22.10',
          ip: '10.16.119.155',
          mac: '00:50:56:9a:61:46',
          mtu: 1500,
          netmask: '255.255.240.0',
          network: '10.16.112.0'
        }

        expect(networking_linux.resolve(:interfaces)['ens160']).to eq(expected)
      end
    end

    context 'when asking for primary interface' do
      before do
        Facter::Util::Resolvers::Networking::PrimaryInterface.instance_variable_set(:@log, log_spy)
        allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_proc_route).and_return(nil)
      end

      context 'when primary interface can not be read from /proc/net/route' do
        before do
          allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_ip_route).and_return('lo')
        end

        it 'returns primary interface' do
          expect(networking_linux.resolve(:primary_interface)).to eq('lo')
        end
      end

      context 'when primary interface can not be read' do
        before do
          allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_ip_route).and_return(nil)
        end

        it 'returns primary interface as the first not ignored ip' do
          expect(networking_linux.resolve(:primary_interface)).to eq('ens160')
        end
      end
    end

    context 'when only ipv6 is available' do
      let(:socket_interfaces) do
        {
          'lo' => {
            bindings6: [
              { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1', scope6: 'host' }
            ]
          },
          'ens160' => {
            bindings6: [
              { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::',
                network: 'fe80::', scope6: 'link' }
            ],
            mac: '00:50:56:9a:61:46'
          }
        }
      end

      let(:result) do
        {
          'lo' => {
            bindings6: [
              { address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1', scope6: 'host' }
            ],
            ip6: '::1',
            mtu: 65_536,
            netmask6: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            network6: '::1',
            scope6: 'host'
          },
          'ens160' => {
            bindings6: [
              { address: 'fe80::250:56ff:fe9a:8481', netmask: 'ffff:ffff:ffff:ffff::',
                network: 'fe80::', scope6: 'link' }
            ],
            ip6: 'fe80::250:56ff:fe9a:8481',
            mac: '00:50:56:9a:61:46',
            mtu: 1500,
            netmask6: 'ffff:ffff:ffff:ffff::',
            network6: 'fe80::',
            scope6: 'link'
          }
        }
      end

      before do
        allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_proc_route).and_return(nil)
        allow(Facter::Util::Resolvers::Networking::PrimaryInterface).to receive(:read_from_ip_route).and_return(nil)
        allow(Facter::Util::Linux::Dhcp).to receive(:dhcp).with('lo', '1', log_spy).and_return(nil)
        allow(Facter::Util::Linux::Dhcp).to receive(:dhcp).with('ens160', '2', log_spy).and_return(nil)
      end

      it 'returns all the interfaces' do
        expect(networking_linux.resolve(:interfaces)).to eq(result)
      end

      it 'returns the primary interface' do
        expect(networking_linux.resolve(:primary_interface)).to be_nil
      end
    end
  end
end
