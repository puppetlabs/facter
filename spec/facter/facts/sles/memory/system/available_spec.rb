# frozen_string_literal: true

describe 'Sles MemorySystemAvailable' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.available', value: '4.56 GiB')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:memfree).and_return(4_900_515_840)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.available', '4.56 GiB').and_return(expected_fact)

      fact = Facter::Sles::MemorySystemAvailable.new
      expect(Facter::BytesToHumanReadable.convert(4_900_515_840)).to eq('4.56 GiB')
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
