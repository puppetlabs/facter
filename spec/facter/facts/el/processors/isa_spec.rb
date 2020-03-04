# frozen_string_literal: true

describe Facts::El::Processors::Isa do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = 'x86_64'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.isa', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.isa', value).and_return(expected_fact)

      fact = Facts::El::Processors::Isa.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
