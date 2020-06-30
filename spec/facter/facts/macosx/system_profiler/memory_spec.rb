# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::Memory do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::Memory.new }

    let(:value) { '16 GB' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:memory).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:memory)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.memory', value: value),
                        an_object_having_attributes(name: 'sp_memory', value: value, type: :legacy))
    end
  end
end
