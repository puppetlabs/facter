# frozen_string_literal: true

describe 'Ubuntu MemorySwapUsed' do
  context '#call_the_resolver' do
    let(:value) { '1.00 KiB' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.used', value: value)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_used_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.used', value).and_return(expected_fact)

      fact = Facter::Debian::MemorySwapUsed.new
      expect(Facter::BytesToHumanReadable.convert(1024)).to eq(value)
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
