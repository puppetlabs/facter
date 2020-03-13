# frozen_string_literal: true

describe Facts::Macosx::Memory::Swap::Total do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Memory::Swap::Total.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:total_bytes).and_return(1024)
    end

    it 'calls Facter::Resolvers::Macosx::SwapMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SwapMemory).to have_received(:resolve).with(:total_bytes)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.total', value: value),
                        an_object_having_attributes(name: 'swapsize', value: value, type: :legacy))
    end
  end
end
