# frozen_string_literal: true

describe 'Ubuntu Facterversion' do
  context '#call_the_resolver' do
    let(:value) { '0.0.5' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'facterversion', value: value)
      allow(Facter::Resolvers::Facterversion).to receive(:resolve).with(:facterversion).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('facterversion', value).and_return(expected_fact)

      fact = Facter::Ubuntu::Facterversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
