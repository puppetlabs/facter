# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::BootMode do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::BootMode.new }

    let(:value) { 'Normal' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:boot_mode).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:boot_mode)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.boot_mode', value: value),
                        an_object_having_attributes(name: 'sp_boot_mode', value: value, type: :legacy))
    end
  end
end
