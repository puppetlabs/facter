# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::HardwareUuid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::HardwareUuid.new }

    let(:value) { '7C3B701F-B88A-56C6-83F4-ACBD450075C4' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:hardware_uuid).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:hardware_uuid)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.hardware_uuid', value: value),
                        an_object_having_attributes(name: 'sp_hardware_uuid', value: value, type: :legacy))
    end
  end
end
