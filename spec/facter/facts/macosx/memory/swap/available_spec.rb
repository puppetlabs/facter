# frozen_string_literal: true

describe Facts::Macosx::Memory::Swap::Available do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Memory::Swap::Available.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:available_bytes).and_return(1024)
    end

    it 'calls Facter::Resolvers::Macosx::SwapMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SwapMemory).to have_received(:resolve).with(:available_bytes)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available', value: value),
                        an_object_having_attributes(name: 'swapfree', value: value, type: :legacy))
    end
  end
end
