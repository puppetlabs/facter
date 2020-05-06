# frozen_string_literal: true

describe Facts::Linux::Memory::Swap::AvailableBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Memory::Swap::AvailableBytes.new }

    let(:value) { 2_332_425 }
    let(:value_mb) { 2.22 }

    before do
      allow(Facter::Resolvers::Linux::Memory).to \
        receive(:resolve).with(:swap_free).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_free)
    end

    it 'returns swap available bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available_bytes', value: value),
                        an_object_having_attributes(name: 'swapfree_mb', value: value_mb, type: :legacy))
    end

    describe '#call_the_resolver when resolver returns nil' do
      let(:value) { nil }

      it 'returns swap available memory in bytes fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'memory.swap.available_bytes', value: value),
                          an_object_having_attributes(name: 'swapfree_mb', value: value, type: :legacy))
      end
    end
  end
end
