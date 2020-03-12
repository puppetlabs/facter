# frozen_string_literal: true

describe Facts::El::SystemUptime::Hours do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::SystemUptime::Hours.new }

    let(:value) { '9' }

    before do
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:hours).and_return(value)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:hours)
    end

    it 'returns hours since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.hours', value: value),
                        an_object_having_attributes(name: 'uptime_hours', value: value, type: :legacy))
    end
  end
end
