# frozen_string_literal: true

describe 'Windows OsFamily' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.family', value: 'value')
      allow(Facter::Resolvers::KernelResolver).to receive(:resolve).with(:kernel).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.family', 'value').and_return(expected_fact)

      fact = Facter::Windows::OsFamily.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
