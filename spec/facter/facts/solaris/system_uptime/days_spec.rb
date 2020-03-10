# frozen_string_literal: true

describe Facts::Solaris::SystemUptime::Days do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::SystemUptime::Days.new }

    let(:value) { '2' }

    before do
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:days).and_return(value)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:days)
    end

    it 'returns days since last boot' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'system_uptime.days', value: value)
    end
  end
end
