# frozen_string_literal: true

describe Facts::Windows::Memory::System::Used do
  describe '#call_the_resolver' do
    let(:value) { '1.00 KiB' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used', value: value)
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:used_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.used', value).and_return(expected_fact)

      fact = Facts::Windows::Memory::System::Used.new
      expect(Facter::BytesToHumanReadable.convert(1024)).to eq(value)
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
