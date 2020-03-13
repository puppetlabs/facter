# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::ComputerName do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::ComputerName.new }

    let(:value) { 'Test1’s MacBook Pro' }

    before do
      allow(Facter::Resolvers::SystemProfiler).to \
        receive(:resolve).with(:computer_name).and_return(value)
    end

    it 'calls Facter::Resolvers::SystemProfiler' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SystemProfiler).to have_received(:resolve).with(:computer_name)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_profiler.computer_name', value: value),
                        an_object_having_attributes(name: 'sp_local_host_name', value: value, type: :legacy))
    end
  end
end
