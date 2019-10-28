# frozen_string_literal: true

describe 'SolarisZone' do
  before do
    status = double(Process::Status, to_s: st)
    expect(Open3).to receive(:capture2)
      .with('/usr/sbin/zoneadm list -cp')
      .ordered
      .and_return([output, status])
  end
  after do
    Facter::Resolvers::SolarisZone.invalidate_cache
  end
  context 'Resolve zone facts' do
    let(:output) { '0:global:running:/::solaris:shared:-:none:' }
    let(:st) { 'exit 0' }
    it 'returns zone fact' do
      hash_fact = [{ brand: 'solaris',
                     id: '0',
                     ip_type: 'shared',
                     name: 'global',
                     uuid: '',
                     status: 'running',
                     path: '/' }]
      result = Facter::Resolvers::SolarisZone.resolve(:zone)
      expect(result).to eq(hash_fact)
    end
  end
end
