# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::Uptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::Uptime.new }

    let(:value) { '26 days 22:12' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:time_since_boot).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:time_since_boot)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.uptime', value: value),
                        an_object_having_attributes(name: 'sp_uptime', value: value, type: :legacy))
    end
  end
end
