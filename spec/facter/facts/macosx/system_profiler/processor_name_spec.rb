# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::ProcessorName do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::ProcessorName.new }

    let(:value) { 'Intel Core i7' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:processor_name).and_return(value)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.processor_name', value: value),
                        an_object_having_attributes(name: 'sp_cpu_type', value: value, type: :legacy))
    end
  end
end
