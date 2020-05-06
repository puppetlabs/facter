# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Ipaddress do
  subject(:ipaddress) { Facter::Resolvers::Macosx::Ipaddress }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#resolve' do
    before do
      ipaddress.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute).with('route -n get default', logger: log_spy)
                                                         .and_return(route)
      allow(Facter::Core::Execution).to receive(:execute).with('ipconfig getifaddr en0', logger: log_spy).and_return(ip)
      allow(Facter::Core::Execution).to receive(:execute).with('ifconfig -a', logger: log_spy).and_return(interfaces)
    end

    after do
      ipaddress.invalidate_cache
    end

    let(:interfaces) { load_fixture('ifconfig_mac').read }
    let(:interfaces_reuslt) { 'en0,lo0,gif0,stf0,XHC20' }
    let(:macaddress) { '64:5a:ed:ea:c3:25' }

    context 'when returns ip' do
      let(:route) { load_fixture('osx_route').read }
      let(:ip) { '10.0.0.1' }

      it 'detects ipadress' do
        expect(ipaddress.resolve(:ip)).to eql(ip)
      end

      it 'detects interfaces' do
        expect(ipaddress.resolve(:interfaces)).to eql(interfaces_reuslt)
      end

      it 'detects macaddress' do
        expect(ipaddress.resolve(:macaddress)).to eql(macaddress)
      end
    end

    context 'when primary interface could not be retrieved' do
      let(:route) { 'invalid output' }
      let(:ip) {}

      it 'detects that ip is nil' do
        expect(ipaddress.resolve(:ip)).to be(nil)
      end
    end
  end
end
