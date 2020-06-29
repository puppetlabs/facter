# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::Cores do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::Cores.new }

    let(:value) { '' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:total_number_of_cores).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:total_number_of_cores)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.cores', value: value),
                        an_object_having_attributes(name: 'sp_number_processors', value: value, type: :legacy))
    end
  end
end
