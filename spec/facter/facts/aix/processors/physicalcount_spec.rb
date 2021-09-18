# frozen_string_literal: true

describe Facts::Aix::Processors::Physicalcount do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Processors::Physicalcount.new }

    let(:physical_count) { '2' }

    before do
      allow(Facter::Resolvers::Aix::Processors).to \
        receive(:resolve).with(:physical_count).and_return(physical_count)
    end

    it 'calls Facter::Resolvers::Aix::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Processors).to have_received(:resolve).with(:physical_count)
    end

    it 'returns processors physical count fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.physicalcount', value: physical_count)
    end
  end
end
