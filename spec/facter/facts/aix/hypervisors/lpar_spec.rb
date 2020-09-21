# frozen_string_literal: true

describe Facts::Aix::Hypervisors::Lpar do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Hypervisors::Lpar.new }

    let(:value) { { 'partition_number' => 13, 'partition_name' => 'aix6-7' } }

    before do
      allow(Facter::Resolvers::Lpar).to receive(:resolve).with(:lpar_partition_number)
                                                         .and_return(value['partition_number'])
      allow(Facter::Resolvers::Lpar).to receive(:resolve).with(:lpar_partition_name)
                                                         .and_return(value['partition_name'])
    end

    it 'calls Facter::Resolvers::Lpar with lpar_partition_number' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Lpar).to have_received(:resolve).with(:lpar_partition_number)
    end

    it 'calls Facter::Resolvers::Lpar with lpar_partition_name' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Lpar).to have_received(:resolve).with(:lpar_partition_name)
    end

    it 'returns a hypervisors.lpar fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'hypervisors.lpar', value: value)
    end
  end
end
