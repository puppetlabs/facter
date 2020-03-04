# frozen_string_literal: true

describe Facts::El::Kernel do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = 'Linux'

      expected_fact = double(Facter::ResolvedFact, name: 'kernel', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernel', value).and_return(expected_fact)

      fact = Facts::El::Kernel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
