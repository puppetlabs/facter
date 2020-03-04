# frozen_string_literal: true

describe Facts::Macosx::Memory::System::Available do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.available', value: '1.0 KiB')

      allow(Facter::Resolvers::Macosx::SystemMemory).to receive(:resolve).with(:available_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.available', '1.0 KiB').and_return(expected_fact)

      expect(Facter::BytesToHumanReadable).to receive(:convert).with(1024).and_return('1.0 KiB')

      fact = Facts::Macosx::Memory::System::Available.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
