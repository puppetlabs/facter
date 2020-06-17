# frozen_string_literal: true

describe Facts::Bsd::Processors::Count do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Bsd::Processors::Count.new }

    let(:processors) { '4' }

    before do
      allow(Facter::Resolvers::Bsd::Processors).to \
        receive(:resolve).with(:logical_count).and_return(processors)
    end

    it 'calls Facter::Resolvers::Bsd::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Bsd::Processors).to have_received(:resolve).with(:logical_count)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.count', value: processors),
                        an_object_having_attributes(name: 'processorcount', value: processors, type: :legacy))
    end
  end
end
