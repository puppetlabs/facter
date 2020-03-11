# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::Total do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Memory::Swap::Total.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_total).and_return(1024)
    end

    it 'calls Facter::Resolvers::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_total)
    end

    it 'returns free memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.total', value: value),
                        an_object_having_attributes(name: 'swapsize', value: value, type: :legacy))
    end
  end
end
