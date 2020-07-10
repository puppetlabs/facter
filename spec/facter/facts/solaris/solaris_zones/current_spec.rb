# frozen_string_literal: true

describe Facts::Solaris::SolarisZones::Current do
  subject(:fact) { Facts::Solaris::SolarisZones::Current.new }

  let(:value) { 'global' }

  before do
    allow(Facter::Resolvers::SolarisZoneName).to receive(:resolve).with(:current_zone_name).and_return('global')
  end

  describe '#call_the_resolver' do
    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(
          an_object_having_attributes(name: 'solaris_zones.current', value: value, type: :core),
          an_object_having_attributes(name: 'zonename', value: value, type: :legacy)
        )
    end
  end
end
