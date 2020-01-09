# frozen_string_literal: true

describe 'Windows SystemUptimeSeconds' do
  context '#call_the_resolver' do
    let(:value) { '34974' }
    subject(:fact) { Facter::Windows::SystemUptimeSeconds.new }

    before do
      allow(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:seconds).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Uptime' do
      expect(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:seconds)
      fact.call_the_resolver
    end

    it 'returns seconds since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.seconds', value: value),
                        an_object_having_attributes(name: 'uptime_seconds', value: value, type: :legacy))
    end
  end
end
