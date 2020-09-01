# frozen_string_literal: true

describe Facts::Freebsd::Memory::Swap::Used do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Memory::Swap::Used.new }

    let(:resolver_result) { 1024 }
    let(:fact_value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Freebsd::SwapMemory).to receive(:resolve).with(:used_bytes).and_return(resolver_result)
    end

    it 'calls Facter::Resolvers::Freebsd::SwapMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::SwapMemory).to have_received(:resolve).with(:used_bytes)
    end

    it 'returns a memory.swap.used fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.swap.used', value: fact_value)
    end
  end
end
