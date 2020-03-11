# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::Used do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Memory::Swap::Used.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_used_bytes).and_return(1024)
    end

    it 'calls Facter::Resolvers::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_used_bytes)
    end

    it 'returns free memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.swap.used', value: value)
    end
  end
end
