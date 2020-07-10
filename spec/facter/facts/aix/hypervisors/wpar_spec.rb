# frozen_string_literal: true

describe Facts::Aix::Hypervisors::Wpar do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Hypervisors::Wpar.new }

    let(:value) { { 'key' => 13, 'configured_id' => 14 } }

    before do
      allow(Facter::Resolvers::Wpar).to receive(:resolve).with(:wpar_key).and_return(value['key'])
      allow(Facter::Resolvers::Wpar).to receive(:resolve).with(:wpar_configured_id).and_return(value['configured_id'])
    end

    it 'calls Facter::Resolvers::Wpar with wpar_key' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Wpar).to have_received(:resolve).with(:wpar_key)
    end

    it 'calls Facter::Resolvers::Wpar with wpar_configured_id' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Wpar).to have_received(:resolve).with(:wpar_configured_id)
    end

    it 'returns a hypervisors.wpar fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'hypervisors.wpar', value: value)
    end
  end
end
