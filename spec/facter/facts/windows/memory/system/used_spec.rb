# frozen_string_literal: true

describe 'Windows MemorySystemUsed' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used', value: '1.0 KiB')
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:used_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.used', '1.0 KiB').and_return(expected_fact)

      fact = Facter::Windows::MemorySystemUsed.new
      expect(Facter::BytesToHumanReadable.convert(1024)).to eq('1.0 KiB')
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
