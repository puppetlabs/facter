# frozen_string_literal: true

describe Facts::Aix::Processors::Count do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Processors::Count.new }

    let(:processors_count) { '32' }

    before do
      allow(Facter::Resolvers::Aix::Processors).to \
        receive(:resolve).with(:logical_count).and_return(processors_count)
    end

    it 'calls Facter::Resolvers::Aix::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Processors).to have_received(:resolve).with(:logical_count)
    end

    it 'returns processors count fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.count', value: processors_count),
                        an_object_having_attributes(name: 'processorcount', value: processors_count, type: :legacy))
    end
  end
end
