# frozen_string_literal: true

describe Facts::Debian::Memory::System::Capacity do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Memory::System::Capacity.new }

    let(:value) { '5.3%' }

    before do
      allow(Facter::Resolvers::Linux::Memory).to \
        receive(:resolve).with(:capacity).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Memory).to have_received(:resolve).with(:capacity)
    end

    it 'returns system memory capacity fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.system.capacity', value: value)
    end
  end
end
