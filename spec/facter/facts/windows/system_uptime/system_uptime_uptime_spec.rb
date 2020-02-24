# frozen_string_literal: true

describe Facter::Windows::SystemUptimeUptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::SystemUptimeUptime.new }

    let(:value) { '9:42 hours' }

    before do
      allow(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:uptime).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Uptime' do
      expect(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:uptime)
      fact.call_the_resolver
    end

    it 'returns time since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.uptime', value: value),
                        an_object_having_attributes(name: 'uptime', value: value, type: :legacy))
    end
  end
end
