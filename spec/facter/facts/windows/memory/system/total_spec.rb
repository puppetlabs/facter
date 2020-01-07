# frozen_string_literal: true

describe 'Windows MemorySystemTotal' do
  context '#call_the_resolver' do
    let(:value) { '1.00 KiB' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.total', value: value)
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:total_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.total', value).and_return(expected_fact)

      fact = Facter::Windows::MemorySystemTotal.new
      expect(Facter::BytesToHumanReadable.convert(1024)).to eq(value)
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
