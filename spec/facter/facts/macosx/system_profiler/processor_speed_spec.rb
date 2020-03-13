# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::ProcessorSpeed do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::ProcessorSpeed.new }

    let(:value) { '2.8 GHz' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:processor_speed).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:processor_speed)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.processor_speed', value: value),
                        an_object_having_attributes(name: 'sp_current_processor_speed', value: value, type: :legacy))
    end
  end
end
