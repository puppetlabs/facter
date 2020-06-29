# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::L3Cache do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::L3Cache.new }

    let(:value) { '6 MB' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:l3_cache).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:l3_cache)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.l3_cache', value: value),
                        an_object_having_attributes(name: 'sp_l3_cache', value: value, type: :legacy))
    end
  end
end
