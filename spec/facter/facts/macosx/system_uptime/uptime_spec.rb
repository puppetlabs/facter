# frozen_string_literal: true

describe Facts::Macosx::SystemUptime::Uptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemUptime::Uptime.new }

    let(:uptime) { '10 days' }

    before do
      allow(Facter::Resolvers::Uptime).to \
        receive(:resolve).with(:uptime).and_return(uptime)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:uptime)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.uptime', value: uptime),
                        an_object_having_attributes(name: 'uptime', value: uptime, type: :legacy))
    end
  end
end
