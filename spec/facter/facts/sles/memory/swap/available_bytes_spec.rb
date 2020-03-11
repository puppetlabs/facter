# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::AvailableBytes do
  subject(:fact) { Facts::Sles::Memory::Swap::AvailableBytes.new }

  before do
    allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_free).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { 3_331_551_232 }
    let(:value_mb) { 3177.21 }

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_free)
    end

    it 'returns available memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available_bytes', value: value),
                        an_object_having_attributes(name: 'swapfree_mb', value: value_mb, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns available memory fact as nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available_bytes', value: value),
                        an_object_having_attributes(name: 'swapfree_mb', value: value, type: :legacy))
    end
  end
end
