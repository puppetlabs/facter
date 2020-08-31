# frozen_string_literal: true

describe Facts::Solaris::Hypervisors::Zone do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Hypervisors::Zone.new }

    before do
      allow(Facter::Resolvers::Solaris::ZoneName).to receive(:resolve)
      allow(Facter::Resolvers::Solaris::Zone).to receive(:resolve)
    end

    context 'when current zone name is nil' do
      let(:current_zone_name) { nil }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
      end

      it 'returns virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.zone', value: nil)
      end
    end

    context 'when zone resolver call is nil' do
      let(:current_zone_name) { 'global' }
      let(:zones) { nil }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Zone).to receive(:resolve).with(:zone).and_return(zones)
      end

      it 'returns current zone details' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.zone', value: nil)
      end
    end

    context 'when current zone name is valid' do
      let(:current_zone_name) { 'global' }
      let(:zones) do
        [
          {
            brand: 'solaris',
            id: 0,
            iptype: 'shared',
            name: 'global',
            uuid: '1234',
            status: 'running',
            path: 'my/path'
          },
          {
            brand: 'solaris',
            id: 1,
            iptype: 'not_shared',
            name: 'global2',
            uuid: '4321',
            status: 'running',
            path: 'my/path'
          }
        ]
      end

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Zone).to receive(:resolve).with(:zone).and_return(zones)
      end

      it 'returns current zone details' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.zone', value: {
                            'brand' => 'solaris',
                            'id' => 0,
                            'ip_type' => 'shared',
                            'name' => 'global',
                            'uuid' => '1234'
                          })
      end
    end
  end
end
