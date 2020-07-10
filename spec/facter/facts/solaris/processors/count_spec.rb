# frozen_string_literal: true

describe Facts::Solaris::Processors::Count do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Processors::Count.new }

    let(:processors) { '4' }

    before do
      allow(Facter::Resolvers::Solaris::Processors).to \
        receive(:resolve).with(:logical_count).and_return(processors)
    end

    it 'calls Facter::Resolvers::Macosx::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Processors).to have_received(:resolve).with(:logical_count)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.count', value: processors),
                        an_object_having_attributes(name: 'processorcount', value: processors, type: :legacy))
    end
  end
end
