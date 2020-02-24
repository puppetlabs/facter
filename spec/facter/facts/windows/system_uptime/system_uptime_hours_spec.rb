# frozen_string_literal: true

describe Facter::Windows::SystemUptimeHours do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::SystemUptimeHours.new }

    let(:value) { '9' }

    before do
      allow(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:hours).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Uptime' do
      expect(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:hours)
      fact.call_the_resolver
    end

    it 'returns hours since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.hours', value: value),
                        an_object_having_attributes(name: 'uptime_hours', value: value, type: :legacy))
    end
  end
end
