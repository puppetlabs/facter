# frozen_string_literal: true

describe Facts::Freebsd::SystemUptime::Uptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::SystemUptime::Uptime.new }

    let(:value) { '6 days' }

    before do
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:uptime).and_return(value)
    end

    it 'returns total uptime since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.uptime', value: value),
                        an_object_having_attributes(name: 'uptime', value: value, type: :legacy))
    end
  end
end
