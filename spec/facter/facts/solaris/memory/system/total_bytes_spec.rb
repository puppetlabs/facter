# frozen_string_literal: true

describe Facts::Solaris::Memory::System::TotalBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Memory::System::TotalBytes.new }

    let(:resolver_output) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:value) { 2_332_999 }
    let(:value_mb) { 2.22 }

    before do
      allow(Facter::Resolvers::Solaris::Memory).to \
        receive(:resolve).with(:system).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::Solaris::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Memory).to have_received(:resolve).with(:system)
    end

    it 'returns system total memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                        an_object_having_attributes(name: 'memorysize_mb', value: value_mb, type: :legacy))
    end

    context 'when resolver returns nil' do
      let(:value) { nil }
      let(:resolver_output) { nil }

      it 'returns system total memory in bytes fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'memory.system.total_bytes', value: value),
                          an_object_having_attributes(name: 'memorysize_mb', value: value, type: :legacy))
      end
    end
  end
end
