# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::ModelName do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::ModelName.new }

    let(:value) { 'MacBook Pro' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:model_name).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:model_name)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.model_name', value: value),
                        an_object_having_attributes(name: 'sp_machine_name', value: value, type: :legacy))
    end
  end
end
