# frozen_string_literal: true

describe Facts::Solaris::Memory::System::Capacity do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Memory::System::Capacity.new }

    let(:resolver_output) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024, capacity: '5.3%' } }
    let(:value) { '5.3%' }

    before do
      allow(Facter::Resolvers::Solaris::Memory).to \
        receive(:resolve).with(:system).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::Solaris::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Memory).to have_received(:resolve).with(:system)
    end

    it 'returns system memory capacity fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.system.capacity', value: value)
    end
  end
end
