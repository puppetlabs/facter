# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::SerialNumber.new }

    let(:value) { 'C02WW1LAG8WL' }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to \
        receive(:resolve).with(:serial_number_system).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:serial_number_system)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.serial_number', value: value),
                        an_object_having_attributes(name: 'sp_serial_number', value: value, type: :legacy))
    end
  end
end
