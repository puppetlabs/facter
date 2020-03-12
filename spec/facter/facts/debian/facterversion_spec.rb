# frozen_string_literal: true

describe Facts::Debian::Facterversion do
  describe '#call_the_resolver' do
    let(:value) { '0.0.5' }

    it 'returns facter version fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'facterversion', value: value)
      allow(Facter::Resolvers::Facterversion).to receive(:resolve).with(:facterversion).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('facterversion', value).and_return(expected_fact)

      fact = Facts::Debian::Facterversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
