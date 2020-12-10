# frozen_string_literal: true

describe Facter::Util::Resolvers::Networking::PrimaryInterface do
  subject(:primary_interface) { Facter::Util::Resolvers::Networking::PrimaryInterface }

  describe '#read_from_route' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .and_return(load_fixture('route_n_get_default').read)
    end

    it 'parses output from `route -n get default`' do
      allow(Facter::Core::Execution).to receive(:which).with('route').and_return('/some/path')
      expect(primary_interface.read_from_route).to eq('net0')
    end

    it 'returns nil if route command does not exist' do
      allow(Facter::Core::Execution).to receive(:which).with('route').and_return(nil)
      expect(primary_interface.read_from_route).to be_nil
    end
  end

  describe '#read_from_proc_route' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with('/proc/net/route', '') \
                                                            .and_return(load_fixture('proc_net_route'))
    end

    it 'parses output /proc/net/route file' do
      expect(primary_interface.read_from_proc_route).to eq('ens160')
    end
  end

  describe '#read_from_ip_route' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .and_return(load_fixture('ip_route_show_default').read)
    end

    it 'parses output from `ip route show default`' do
      allow(Facter::Core::Execution).to receive(:which).with('ip').and_return('/some/path')
      expect(primary_interface.read_from_ip_route).to eq('ens160')
    end

    it 'returns nil if route command does not exist' do
      allow(Facter::Core::Execution).to receive(:which).with('ip').and_return(nil)
      expect(primary_interface.read_from_ip_route).to be_nil
    end
  end

  describe '#find_in_interfaces' do
    let(:interfaces) do
      { 'lo' =>
        { bindings: [{ address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }],
          bindings6: [{
            address: '::1',
            netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            network: '::1',
            scope6: 'host'
          }],
          scope6: 'host',
          mtu: 65_536 },
        'ens160' =>
        { bindings: [{ address: '10.16.124.1', netmask: '255.255.240.0', network: '10.16.112.0' }],
          dhcp: '10.32.22.9',
          bindings6: [{
            address: 'fe80::250:56ff:fe9a:41fc',
            netmask: 'ffff:ffff:ffff:ffff::',
            network: 'fe80::',
            scope6: 'link'
          }],
          scope6: 'link',
          mac: '00:50:56:9a:41:fc',
          mtu: 1500 } }
    end

    it 'parses interfaces to find primary interface' do
      expect(primary_interface.find_in_interfaces(interfaces)).to eq('ens160')
    end
  end
end
