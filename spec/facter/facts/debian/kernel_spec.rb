# frozen_string_literal: true

describe Facts::Debian::Kernel do
  describe '#call_the_resolver' do
    let(:value) { 'Linux' }

    it 'returns kernel fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernel', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernel', value).and_return(expected_fact)

      fact = Facts::Debian::Kernel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
