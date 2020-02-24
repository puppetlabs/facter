# frozen_string_literal: true

describe Facter::Windows::MemorySystemTotal do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::MemorySystemTotal.new }

    let(:value) { '1.00 KiB' }

    before do
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:total_bytes).and_return(1024)
    end

    it 'calls Facter::Resolvers::Memory' do
      expect(Facter::Resolvers::Memory).to receive(:resolve).with(:total_bytes)
      fact.call_the_resolver
    end

    it 'returns memory size fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total', value: value),
                        an_object_having_attributes(name: 'memorysize', value: value, type: :legacy))
    end
  end
end
