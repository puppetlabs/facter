# frozen_string_literal: true

describe Facts::Sles::SystemUptime::Uptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::SystemUptime::Uptime.new }

    let(:value) { '9:42 hours' }

    before do
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:uptime).and_return(value)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:uptime)
    end

    it 'returns time since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.uptime', value: value),
                        an_object_having_attributes(name: 'uptime', value: value, type: :legacy))
    end
  end
end
