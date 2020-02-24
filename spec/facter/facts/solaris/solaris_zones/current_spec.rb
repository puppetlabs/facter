# frozen_string_literal: true

describe Facter::Solaris::SolarisZonesCurrent do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'solaris_zones.current', value: 'global')
      allow(Facter::Resolvers::SolarisZoneName).to receive(:resolve).with(:current_zone_name).and_return('global')
      allow(Facter::ResolvedFact).to receive(:new).with('solaris_zones.current', 'global').and_return(expected_fact)

      fact = Facter::Solaris::SolarisZonesCurrent.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
