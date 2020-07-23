# frozen_string_literal: true

describe Facts::Aix::Memory::Swap::Available do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Memory::Swap::Available.new }

    let(:value) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:result) { '2.22 MiB' }

    before do
      allow(Facter::Resolvers::Aix::Memory).to \
        receive(:resolve).with(:swap).and_return(value)
    end

    it 'calls Facter::Resolvers::Aix::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Memory).to have_received(:resolve).with(:swap)
    end

    it 'returns swap available memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available', value: result),
                        an_object_having_attributes(name: 'swapfree', value: result, type: :legacy))
    end
  end
end
