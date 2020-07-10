# frozen_string_literal: true

describe Facts::Windows::Memory::System::UsedBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used_bytes', value: 1024)
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:used_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.used_bytes', 1024).and_return(expected_fact)

      fact = Facts::Windows::Memory::System::UsedBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
