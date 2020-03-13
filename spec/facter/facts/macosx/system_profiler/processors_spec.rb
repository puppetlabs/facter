# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::Processors do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::Processors.new }

    let(:value) { '1' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:number_of_processors).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:number_of_processors)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.processors', value: value),
                        an_object_having_attributes(name: 'sp_cpu_type', value: value, type: :legacy))
    end
  end
end
