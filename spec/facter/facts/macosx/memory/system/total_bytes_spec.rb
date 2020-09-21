# frozen_string_literal: true

describe Facts::Macosx::Memory::System::TotalBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Memory::System::TotalBytes.new }

    let(:value) { 1024 * 1024 }
    let(:value_mb) { 1 }

    before do
      allow(Facter::Resolvers::Macosx::SystemMemory).to receive(:resolve).with(:total_bytes).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemMemory).to have_received(:resolve).with(:total_bytes)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                        an_object_having_attributes(name: 'memorysize_mb', value: value_mb, type: :legacy))
    end
  end
end
