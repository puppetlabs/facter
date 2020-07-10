# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Ipaddress do
  subject(:ipaddress) { Facter::Resolvers::Solaris::Ipaddress }

  let(:log) { instance_spy(Facter::Log) }

  describe '#resolve' do
    after do
      ipaddress.invalidate_cache
    end

    before do
      ipaddress.instance_variable_set(:@log, log)
      allow(Facter::Core::Execution).to receive(:execute).with('route -n get default | grep interface',
                                                               logger: log).and_return(route)
    end

    context 'when returns ip' do
      let(:route) { '  interface: net0' }
      let(:ifconfig) { load_fixture('solaris_ifconfig').read }

      before do
        allow(Facter::Core::Execution).to receive(:execute).with('ifconfig net0', logger: log).and_return(ifconfig)
      end

      it 'detects ipadress' do
        expect(ipaddress.resolve(:ip)).to eql('10.16.115.67')
      end
    end

    context 'when primary interface could not be retrieved' do
      let(:route) { 'invalid output' }

      it 'detects that ip is nil' do
        expect(ipaddress.resolve(:ip)).to be(nil)
      end
    end
  end
end
