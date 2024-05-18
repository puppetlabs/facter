# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Zone do
  subject(:solaris_zone) { Facter::Resolvers::Solaris::Zone }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/sbin/zoneadm list -cp', logger: an_instance_of(Facter::Log))
      .and_return(output)
  end

  after do
    solaris_zone.invalidate_cache
  end

  context 'when it can resolve zone facts' do
    let(:output) { '0:global:running:/::solaris:shared:-:none:' }
    let(:zone) do
      [{ brand: 'solaris',
         id: '0',
         iptype: 'shared',
         name: 'global',
         uuid: '',
         status: 'running',
         path: '/' }]
    end

    it 'returns zone fact' do
      expect(solaris_zone.resolve(:zone)).to eq(zone)
    end
  end

  context 'when it can not resolve zone facts' do
    let(:output) { '' }

    it 'prints debug message' do
      expect(solaris_zone.log).to receive(:debug)
        .with('Command /usr/sbin/zoneadm list -cp returned an empty result')

      solaris_zone.resolve(:zone)
    end
  end
end
