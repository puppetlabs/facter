# frozen_string_literal: true

describe Facts::Macosx::Memory::System::Total do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Memory::System::Total.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Macosx::SystemMemory).to receive(:resolve).with(:total_bytes).and_return(1024)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total', value: value),
                        an_object_having_attributes(name: 'memorysize', value: value, type: :legacy))
    end
  end
end
