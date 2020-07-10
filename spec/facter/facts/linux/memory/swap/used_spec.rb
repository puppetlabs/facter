# frozen_string_literal: true

describe Facts::Linux::Memory::Swap::Used do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Memory::Swap::Used.new }

    let(:resolver_value) { 1024 }
    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Linux::Memory).to \
        receive(:resolve).with(:swap_used_bytes).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_used_bytes)
    end

    it 'returns swap used memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.swap.used', value: value)
    end
  end
end
