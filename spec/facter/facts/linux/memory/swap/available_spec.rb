# frozen_string_literal: true

describe Facts::Linux::Memory::Swap::Available do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Memory::Swap::Available.new }

    let(:resolver_value) { 1024 }
    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Linux::Memory).to \
        receive(:resolve).with(:swap_free).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:swap_free)
    end

    it 'returns swap available memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.available', value: value),
                        an_object_having_attributes(name: 'swapfree', value: value, type: :legacy))
    end
  end
end
