# frozen_string_literal: true

describe Facts::Aix::SystemUptime::Days do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::SystemUptime::Days.new }

    let(:days) { '11' }

    before do
      allow(Facter::Resolvers::Uptime).to \
        receive(:resolve).with(:days).and_return(days)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:days)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'system_uptime.days', value: days)
    end
  end
end
