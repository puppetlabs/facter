# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::UsedBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Memory::Swap::UsedBytes.new }

    let(:value) {  1024 }

    before do
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_used_bytes).and_return(value)
    end

    it 'calls Facter::Resolvers::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_used_bytes)
    end

    it 'returns free memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.swap.used_bytes', value: value)
    end
  end
end
