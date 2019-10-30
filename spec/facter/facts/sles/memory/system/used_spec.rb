# frozen_string_literal: true

describe 'Sles MemorySystemUsed' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used', value: '1.25 GiB')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:used_bytes).and_return(1_342_128_128)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.used', '1.25 GiB').and_return(expected_fact)

      fact = Facter::Sles::MemorySystemUsed.new
      expect(Facter::BytesToHumanReadable.convert(1_342_128_128)).to eq('1.25 GiB')
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
