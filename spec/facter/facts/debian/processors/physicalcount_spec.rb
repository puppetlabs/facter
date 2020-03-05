# frozen_string_literal: true

describe Facts::Debian::Processors::Physicalcount do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Processors::Physicalcount.new }

    let(:physical_count) { '2' }

    before do
      allow(Facter::Resolvers::Linux::Processors).to \
        receive(:resolve).with(:physical_count).and_return(physical_count)
    end

    it 'calls Facter::Resolvers::Linux::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Processors).to have_received(:resolve).with(:physical_count)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.physicalcount', value: physical_count)
    end
  end
end
