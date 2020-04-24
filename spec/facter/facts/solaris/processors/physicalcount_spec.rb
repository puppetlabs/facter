# frozen_string_literal: true

describe Facts::Solaris::Processors::Physicalcount do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Processors::Physicalcount.new }

    let(:physicalcount) { '5' }

    before do
      allow(Facter::Resolvers::Solaris::Processors).to \
        receive(:resolve).with(:physical_count).and_return(physicalcount)
    end

    it 'calls Facter::Resolvers::Macosx::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Processors).to have_received(:resolve).with(:physical_count)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.physicalcount', value: physicalcount),
                        an_object_having_attributes(name: 'physicalprocessorcount', value: physicalcount,
                                                    type: :legacy))
    end
  end
end
