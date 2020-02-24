# frozen_string_literal: true

describe Facter::Sles::MemorySystemTotal do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.total', value: '5.81 GiB')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:total).and_return(6_242_643_968)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.total', '5.81 GiB').and_return(expected_fact)

      fact = Facter::Sles::MemorySystemTotal.new
      expect(Facter::BytesToHumanReadable.convert(6_242_643_968)).to eq('5.81 GiB')
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
