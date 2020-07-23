# frozen_string_literal: true

describe Facts::Aix::Memory::Swap::UsedBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Memory::Swap::UsedBytes.new }

    let(:value) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:result) { 1024 }

    before do
      allow(Facter::Resolvers::Aix::Memory).to \
        receive(:resolve).with(:swap).and_return(value)
    end

    it 'calls Facter::Resolvers::Aix::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Memory).to have_received(:resolve).with(:swap)
    end

    it 'returns swap used memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.swap.used_bytes', value: result)
    end
  end
end
