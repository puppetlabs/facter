# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::L2CachePerCore do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::L2CachePerCore.new }

    let(:value) { '256 KB' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:l2_cache_per_core).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:l2_cache_per_core)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.l2_cache_per_core', value: value),
                        an_object_having_attributes(name: 'sp_l2_cache_per_core', value: value, type: :legacy))
    end
  end
end
