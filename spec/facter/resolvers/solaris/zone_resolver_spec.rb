# frozen_string_literal: true

describe Facter::Resolvers::SolarisZone do
  subject(:solaris_zone) { Facter::Resolvers::SolarisZone }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    solaris_zone.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/sbin/zoneadm list -cp', logger: log_spy)
      .ordered
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
      solaris_zone.resolve(:zone)
      expect(log_spy).to have_received(:debug)
        .with('Command /usr/sbin/zoneadm list -cp returned an empty result')
    end
  end
end
