# frozen_string_literal: true

describe Facter::Util::Linux::RoutingTable do
  subject(:routing_parser) { Facter::Util::Linux::RoutingTable }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#read_routing_table' do
    context 'when ip route show finds an IP, Socket lib did not retrieve' do
      before do
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip route show', logger: log_spy).and_return(load_fixture('ip_route_show').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('ip -6 route show', logger: log_spy).and_return(load_fixture('ip_-6_route_show').read)
      end

      it 'returns the ipv4 info' do
        expected = [{ interface: 'ens192', ip: '10.16.125.217' }]

        expect(routing_parser.read_routing_table(log_spy)[0]).to eq(expected)
      end

      it 'returns no ipv6 info' do
        expect(routing_parser.read_routing_table(log_spy)[1]).to eq([])
      end
    end
  end
end
