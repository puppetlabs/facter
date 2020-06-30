# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::BootRomVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::BootRomVersion.new }

    let(:value) { '194.0.0.0.0' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:boot_rom_version).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:boot_rom_version)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.boot_rom_version', value: value),
                        an_object_having_attributes(name: 'sp_boot_rom_version', value: value, type: :legacy))
    end
  end
end
