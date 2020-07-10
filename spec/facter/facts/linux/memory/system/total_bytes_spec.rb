# frozen_string_literal: true

describe Facts::Linux::Memory::System::TotalBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Memory::System::TotalBytes.new }

    let(:value) { 2_332_425 }
    let(:value_mb) { 2.22 }

    before do
      allow(Facter::Resolvers::Linux::Memory).to \
        receive(:resolve).with(:total).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:total)
    end

    it 'returns system total memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                        an_object_having_attributes(name: 'memorysize_mb', value: value_mb, type: :legacy))
    end

    describe '#call_the_resolver when resolver returns nil' do
      let(:value) { nil }

      it 'returns system total memory in bytes fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                          an_object_having_attributes(name: 'memorysize_mb', value: value, type: :legacy))
      end
    end
  end
end
