# frozen_string_literal: true

describe Facts::Linux::AioAgentVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::AioAgentVersion.new }

    let(:value) { '1.2.3' }

    before do
      allow(Facter::Resolvers::AioAgentVersion).to receive(:resolve).with(:aio_agent_version).and_return(value)
    end

    it 'calls Facter::Resolvers::Agent' do
      fact.call_the_resolver
      expect(Facter::Resolvers::AioAgentVersion).to have_received(:resolve).with(:aio_agent_version)
    end

    it 'returns aio_agent_version fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'aio_agent_version', value: value)
    end
  end
end
