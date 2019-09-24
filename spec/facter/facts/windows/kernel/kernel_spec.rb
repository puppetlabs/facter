# frozen_string_literal: true

describe 'Windows Kernel' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernel', value: 'value')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernel).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('kernel', 'value').and_return(expected_fact)

      fact = Facter::Windows::Kernel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
