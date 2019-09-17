# frozen_string_literal: true

describe 'Windows MemorySystemTotalBytes' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.total_bytes', value: 1024)
      allow(MemoryResolver).to receive(:resolve).with(:total_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.total_bytes', 1024).and_return(expected_fact)

      fact = Facter::Windows::MemorySystemTotalBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
