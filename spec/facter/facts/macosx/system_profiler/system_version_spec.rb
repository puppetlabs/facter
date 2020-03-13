# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::SystemVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::SystemVersion.new }

    let(:value) { 'macOS 10.14.6 (18G95)' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:system_version).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:system_version)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.system_version', value: value),
                        an_object_having_attributes(name: 'sp_os_version', value: value, type: :legacy))
    end
  end
end
