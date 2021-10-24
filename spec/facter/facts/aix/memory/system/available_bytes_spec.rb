# frozen_string_literal: true

describe Facts::Aix::Memory::System::AvailableBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Memory::System::AvailableBytes.new }

    let(:resolver_output) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:value) { 2_332_425 }
    let(:value_mb) { 2.2243738174438477 }

    before do
      allow(Facter::Resolvers::Aix::Memory).to \
        receive(:resolve).with(:system).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::Aix::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Memory).to have_received(:resolve).with(:system)
    end

    it 'returns system available memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'memory.system.available_bytes', value: value),
                        an_object_having_attributes(name: 'memoryfree_mb', value: value_mb, type: :legacy))
    end

    context 'when resolver returns nil' do
      let(:value) { nil }
      let(:resolver_output) { nil }

      it 'returns system available memory in bytes fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'memory.system.available_bytes', value: value),
                          an_object_having_attributes(name: 'memoryfree_mb', value: value, type: :legacy))
      end
    end
  end
end
