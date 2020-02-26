# frozen_string_literal: true

describe Facter::Aix::HypervisorsLpar do
  describe '#call_the_resolver' do
    it 'returns a lpar hypervisor fact' do
      expected_fact_name = 'hypervisors.lpar'
      expected_fact_value = { 'partition_number' => 13, 'partition_name' => 'aix6-7' }
      allow(Facter::Resolvers::Lpar).to receive(:resolve).with(:lpar_partition_number).and_return(13)
      allow(Facter::Resolvers::Lpar).to receive(:resolve).with(:lpar_partition_name).and_return('aix6-7')

      fact = Facter::Aix::HypervisorsLpar.new.call_the_resolver

      expect(fact.name).to eq(expected_fact_name)
      expect(fact.value).to eq(expected_fact_value)
    end
  end
end
