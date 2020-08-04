# frozen_string_literal: true

describe Facts::Solaris::Memory::Swap::Total do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Memory::Swap::Total.new }

    let(:value) { { available_bytes: 24, total_bytes: 1024, used_bytes: 1000 } }
    let(:result) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Solaris::Memory).to \
        receive(:resolve).with(:swap).and_return(value)
    end

    it 'calls Facter::Resolvers::Solaris::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Memory).to have_received(:resolve).with(:swap)
    end

    it 'returns swap total memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.total', value: result),
                        an_object_having_attributes(name: 'swapsize', value: result, type: :legacy))
    end
  end
end
