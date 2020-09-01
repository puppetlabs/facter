# frozen_string_literal: true

describe Facts::Solaris::Memory::Swap::TotalBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Memory::Swap::TotalBytes.new }

    let(:value) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:result) { 2_332_999 }
    let(:value_mb) { 2.22 }

    before do
      allow(Facter::Resolvers::Solaris::Memory).to \
        receive(:resolve).with(:swap).and_return(value)
    end

    it 'calls Facter::Resolvers::Solaris::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Memory).to have_received(:resolve).with(:swap)
    end

    it 'returns swap total memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.total_bytes', value: result),
                        an_object_having_attributes(name: 'swapsize_mb', value: value_mb, type: :legacy))
    end

    context 'when resolver returns nil' do
      let(:value) { nil }

      it 'returns swap total memory in bytes fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'memory.swap.total_bytes', value: value),
                          an_object_having_attributes(name: 'swapsize_mb', value: value, type: :legacy))
      end
    end
  end
end
