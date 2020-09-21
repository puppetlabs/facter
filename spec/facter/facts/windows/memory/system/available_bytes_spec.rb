# frozen_string_literal: true

describe Facts::Windows::Memory::System::AvailableBytes do
  subject(:fact) { Facts::Windows::Memory::System::AvailableBytes.new }

  before do
    allow(Facter::Resolvers::Memory).to receive(:resolve).with(:available_bytes).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { 3_331_551_232 }
    let(:value_mb) { '3177.21' }

    it 'calls Facter::Resolvers::Memory' do
      expect(Facter::Resolvers::Memory).to receive(:resolve).with(:available_bytes)
      fact.call_the_resolver
    end

    it 'returns available memory fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.available_bytes', value: value),
                        an_object_having_attributes(name: 'memoryfree_mb', value: value_mb, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns available memory fact as nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.available_bytes', value: value),
                        an_object_having_attributes(name: 'memoryfree_mb', value: value, type: :legacy))
    end
  end
end
