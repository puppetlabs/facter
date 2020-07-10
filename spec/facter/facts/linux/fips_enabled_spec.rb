# frozen_string_literal: true

describe Facts::Linux::FipsEnabled do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::FipsEnabled.new }

    let(:value) { true }

    before do
      allow(Facter::Resolvers::Linux::FipsEnabled).to \
        receive(:resolve).with(:fips_enabled).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::FipsEnabled' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::FipsEnabled).to have_received(:resolve).with(:fips_enabled)
    end

    it 'returns fips enabled fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'fips_enabled', value: value)
    end
  end
end
