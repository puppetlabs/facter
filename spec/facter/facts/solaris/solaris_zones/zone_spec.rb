# frozen_string_literal: true

describe Facts::Solaris::SolarisZones::Zone do
  describe '#call_the_resolver' do
    # let(:zone_name){"global"}
    it 'returns a fact' do
      zone_name = 'global'
      array_of_hashes = [{ brand: 'solaris',
                           id: '0',
                           ip_type: 'shared',
                           name: 'global',
                           uuid: '',
                           status: nil,
                           path: nil }]
      result_fact = { zone_name.to_sym => {   brand: 'solaris',
                                              id: '0',
                                              ip_type: 'shared',
                                              status: nil,
                                              path: nil } }
      expected_fact = double(Facter::ResolvedFact, name: 'solaris_zones.zones', value: result_fact)
      allow(Facter::Resolvers::SolarisZone).to receive(:resolve).with(:zone).and_return(array_of_hashes)
      allow(Facter::ResolvedFact).to receive(:new).with('solaris_zones.zones', result_fact).and_return(expected_fact)

      fact = Facts::Solaris::SolarisZones::Zone.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
