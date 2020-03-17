# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Ipaddress do
  describe '#resolve' do
    before do
      allow(Open3).to receive(:capture2).with('route -n get default').and_return(route)
      allow(Open3).to receive(:capture2).with('ipconfig getifaddr en0').and_return(ip)
      allow(Open3).to receive(:capture2).with('ifconfig -a 2>/dev/null').and_return(interfaces)
    end

    after do
      Facter::Resolvers::Macosx::Ipaddress.invalidate_cache
    end

    let(:interfaces) { load_fixture('ifconfig_mac').read }
    let(:interfaces_reuslt) { 'en0,lo0,gif0,stf0,XHC20' }
    let(:macaddress) { '64:5a:ed:ea:c3:25' }

    context 'when returns ip' do
      let(:route) { load_fixture('osx_route').read }
      let(:ip) { '10.0.0.1' }

      it 'detects ipadress' do
        expect(Facter::Resolvers::Macosx::Ipaddress.resolve(:ip)).to eql(ip)
      end

      it 'detects interfaces' do
        expect(Facter::Resolvers::Macosx::Ipaddress.resolve(:interfaces)).to eql(interfaces_reuslt)
      end

      it 'detects macaddress' do
        expect(Facter::Resolvers::Macosx::Ipaddress.resolve(:macaddress)).to eql(macaddress)
      end
    end

    context 'when primary interface could not be retrieved' do
      let(:route) { 'invalid output' }
      let(:ip) {}

      it 'detects that ip is nil' do
        expect(Facter::Resolvers::Macosx::Ipaddress.resolve(:ip)).to be(nil)
      end
    end
  end
end
