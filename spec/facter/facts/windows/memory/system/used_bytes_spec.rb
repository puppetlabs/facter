# frozen_string_literal: true

describe 'Windows MemorySystemUsedBytes' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used_bytes', value: 1024)
      allow(MemoryResolver).to receive(:resolve).with(:used_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.used_bytes', 1024).and_return(expected_fact)

      fact = Facter::Windows::MemorySystemUsedBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
