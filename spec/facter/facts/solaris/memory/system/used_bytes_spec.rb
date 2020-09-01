# frozen_string_literal: true

describe Facts::Solaris::Memory::System::UsedBytes do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Memory::System::UsedBytes.new }

    let(:resolver_output) { { available_bytes: 2_332_425, total_bytes: 2_332_999, used_bytes: 1024 } }
    let(:value) { 1024 }

    before do
      allow(Facter::Resolvers::Solaris::Memory).to \
        receive(:resolve).with(:system).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::Solaris::Memory' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Memory).to have_received(:resolve).with(:system)
    end

    it 'returns system used memory in bytes fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'memory.system.used_bytes', value: value)
    end
  end
end
