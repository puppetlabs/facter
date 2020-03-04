# frozen_string_literal: true

describe Facts::Debian::SystemUptime::Uptime do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::SystemUptime::Uptime.new }

    let(:value) { '6 days' }

    before do
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:uptime).and_return(value)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:uptime)
    end

    it 'returns total uptime since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'system_uptime.uptime', value: value)
    end
  end
end
