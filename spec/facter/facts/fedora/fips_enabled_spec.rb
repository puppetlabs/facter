# frozen_string_literal: true

describe 'Fedora FipsEnabled' do
  context '#call_the_resolver' do
    let(:value) { false }
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'fips_enabled', value: value)
      allow(Facter::Resolvers::Linux::FipsEnabled).to receive(:resolve).with(:fips_enabled).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('fips_enabled', value).and_return(expected_fact)

      fact = Facter::Fedora::FipsEnabled.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
