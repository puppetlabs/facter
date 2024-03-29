# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::BootVolume do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::BootVolume.new }

    let(:value) { 'Macintosh HD' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:boot_volume).and_return(value)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.boot_volume', value: value),
                        an_object_having_attributes(name: 'sp_boot_volume', value: value, type: :legacy))
    end
  end
end
