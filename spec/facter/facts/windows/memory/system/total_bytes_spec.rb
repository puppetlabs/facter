# frozen_string_literal: true

describe 'Windows MemorySystemTotalBytes' do
  context '#call_the_resolver' do
    let(:value) { 3_331_551_232 }
    let(:value_mb) { 3177.21 }
    subject(:fact) { Facter::Windows::MemorySystemTotalBytes.new }

    before do
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:total_bytes).and_return(value)
    end

    it 'calls Facter::Resolvers::Memory' do
      expect(Facter::Resolvers::Memory).to receive(:resolve).with(:total_bytes)
      fact.call_the_resolver
    end

    it 'returns total memory im bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                        an_object_having_attributes(name: 'memorysize_mb', value: value_mb, type: :legacy))
    end
  end
end
