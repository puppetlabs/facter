# frozen_string_literal: true

describe Facter::Aix::HypervisorsWpar do
  describe '#call_the_resolver' do
    it 'returns a wpar only hypervisor fact' do
      expected_fact_name = 'hypervisors.wpar'
      expected_fact_value = { 'key' => 13, 'configured_id' => 14 }
      allow(Facter::Resolvers::Wpar).to receive(:resolve).with(:wpar_key).and_return(13)
      allow(Facter::Resolvers::Wpar).to receive(:resolve).with(:wpar_configured_id).and_return(14)

      fact = Facter::Aix::HypervisorsWpar.new.call_the_resolver

      expect(fact.name).to eq(expected_fact_name)
      expect(fact.value).to eq(expected_fact_value)
    end
  end
end
