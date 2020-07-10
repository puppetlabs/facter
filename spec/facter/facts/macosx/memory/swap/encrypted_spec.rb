# frozen_string_literal: true

describe Facts::Macosx::Memory::Swap::Encrypted do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Memory::Swap::Encrypted.new }

    let(:value) { true }

    before do
      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:encrypted).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SwapMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SwapMemory).to have_received(:resolve).with(:encrypted)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.swap.encrypted', value: value),
                        an_object_having_attributes(name: 'swapencrypted', value: value, type: :legacy))
    end
  end
end
