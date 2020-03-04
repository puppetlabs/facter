# frozen_string_literal: true

describe Facts::Macosx::Processors::Count do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Processors::Count.new }

    let(:processors) { '4' }

    before do
      allow(Facter::Resolvers::Macosx::Processors).to \
        receive(:resolve).with(:logicalcount).and_return(processors)
    end

    it 'calls Facter::Resolvers::Macosx::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Processors).to have_received(:resolve).with(:logicalcount)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.count', value: processors)
    end
  end
end
