# frozen_string_literal: true

describe Facts::Windows::Identity::Privileged do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'identity.privileged', value: 'value')
      allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('identity.privileged', 'value').and_return(expected_fact)

      fact = Facts::Windows::Identity::Privileged.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
