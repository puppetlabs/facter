# frozen_string_literal: true

describe Facts::Freebsd::Memory::System::Capacity do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Memory::System::Capacity.new }

    let(:value) { '15.53%' }

    before do
      allow(Facter::Resolvers::Freebsd::SystemMemory).to receive(:resolve).with(:capacity).and_return(value)
    end

    it 'calls Facter::Resolvers::Freebsd::SystemMemory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::SystemMemory).to have_received(:resolve).with(:capacity)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.system.capacity', value: value)
    end
  end
end
