# frozen_string_literal: true

describe Facts::Sles::Kernel do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernel', value: 'Linux')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return('Linux')
      allow(Facter::ResolvedFact).to receive(:new).with('kernel', 'Linux').and_return(expected_fact)

      fact = Facts::Sles::Kernel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
