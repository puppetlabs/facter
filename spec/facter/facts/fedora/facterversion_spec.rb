# frozen_string_literal: true

describe 'Fedora Facterversion' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'facterversion', value: '0.0.10')
      allow(Facter::Resolvers::Facterversion).to receive(:resolve).with(:facterversion).and_return('0.0.10')
      allow(Facter::ResolvedFact).to receive(:new).with('facterversion', '0.0.10').and_return(expected_fact)

      fact = Facter::Fedora::Facterversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
