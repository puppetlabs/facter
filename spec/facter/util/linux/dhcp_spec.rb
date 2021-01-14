# frozen_string_literal: true

describe Facter::Util::Linux::Dhcp do
  subject(:dhcp_search) { Facter::Util::Linux::Dhcp }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#dhcp' do
    context 'when lease file has the dhcp' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/run/systemd/netif/leases/2', nil).and_return(load_fixture('dhcp_lease').read)
      end

      it 'returns dhcp ip' do
        expect(dhcp_search.dhcp('ens160', 2, log_spy)).to eq('10.32.22.10')
      end
    end

    context 'when dhclient lease file has the dhcp' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/1', nil).and_return(nil)
        allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(true)
        allow(Dir).to receive(:entries).with('/var/lib/dhclient/').and_return(%w[dhclient.lo.leases dhclient.leases])
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/var/lib/dhclient/dhclient.lo.leases', nil).and_return(load_fixture('dhclient_lease').read)
      end

      it 'returns dhcp ip' do
        expect(dhcp_search.dhcp('lo', 1, log_spy)).to eq('10.32.22.9')
      end
    end

    context 'when dhcp is available in the internal leases' do
      # missing fixture for internal.<interface_name>.lease file
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/1', nil).and_return(nil)
        allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp3/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/NetworkManager/').and_return(true)
        allow(Dir).to receive(:entries).with('/var/lib/NetworkManager/').and_return(['internal.lo.lease'])
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/var/lib/NetworkManager/internal.lo.lease', nil).and_return('SERVER_ADDRESS=10.32.22.9')
        allow(File).to receive(:readable?).with('/var/db/').and_return(false)
      end

      it 'returns dhcp ip' do
        expect(dhcp_search.dhcp('lo', 1, log_spy)).to eq('10.32.22.9')
      end
    end

    context 'when dhcp is available through the dhcp command' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/run/systemd/netif/leases/1', nil).and_return(nil)
        allow(File).to receive(:readable?).with('/var/lib/dhclient/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/dhcp3/').and_return(false)
        allow(File).to receive(:readable?).with('/var/lib/NetworkManager/').and_return(false)
        allow(File).to receive(:readable?).with('/var/db/').and_return(false)

        allow(Facter::Core::Execution).to receive(:execute)
          .with('dhcpcd -U ens160', logger: log_spy).and_return(load_fixture('dhcpcd').read)
      end

      it 'returns dhcp ip' do
        expect(dhcp_search.dhcp('ens160', 1, log_spy)).to eq('10.32.22.9')
      end
    end
  end
end
