# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Ipaddress do
  describe '#resolve' do
    after do
      Facter::Resolvers::Solaris::Ipaddress.invalidate_cache
    end

    context 'when returns ip' do
      let(:route) { '  interface: net0' }
      let(:ifconfig) { load_fixture('solaris_ifconfig').read }

      it 'detects ipadress' do
        allow(Open3).to receive(:capture2).with('route -n get default | grep interface').and_return(route)
        allow(Open3).to receive(:capture2).with('ifconfig net0').and_return(ifconfig)
        expect(Facter::Resolvers::Solaris::Ipaddress.resolve(:ip)).to eql('10.16.115.67')
      end
    end

    context 'when primary interface could not be retrieved' do
      let(:route) { 'invalid output' }

      it 'detects that ip is nil' do
        allow(Open3).to receive(:capture2).with('route -n get default | grep interface').and_return(route)
        expect(Facter::Resolvers::Solaris::Ipaddress.resolve(:ip)).to be(nil)
      end
    end
  end
end
