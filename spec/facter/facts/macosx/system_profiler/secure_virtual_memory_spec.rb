# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::SecureVirtualMemory do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::SecureVirtualMemory.new }

    let(:value) { 'Enabled' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:secure_virtual_memory).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:secure_virtual_memory)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.secure_virtual_memory', value: value),
                        an_object_having_attributes(name: 'sp_secure_vm', value: value, type: :legacy))
    end
  end
end
