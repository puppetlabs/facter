# frozen_string_literal: true

describe Facts::Windows::FipsEnabled do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::FipsEnabled.new }

    let(:value) { true }

    before do
      allow(Facter::Resolvers::Windows::Fips).to receive(:resolve).with(:fips_enabled).and_return(value)
    end

    it 'calls Facter::Windows::Resolvers::Fips' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Windows::Fips).to have_received(:resolve).with(:fips_enabled)
    end

    it 'returns true if fips enabled' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'fips_enabled', value: true)
    end
  end
end
