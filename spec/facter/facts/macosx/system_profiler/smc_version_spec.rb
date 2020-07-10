# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::SmcVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::SmcVersion.new }

    let(:value) { '2.29f24' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:smc_version_system).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:smc_version_system)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.smc_version', value: value),
                        an_object_having_attributes(name: 'sp_smc_version_system', value: value, type: :legacy))
    end
  end
end
