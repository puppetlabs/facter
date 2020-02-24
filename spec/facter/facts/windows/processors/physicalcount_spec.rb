# frozen_string_literal: true

describe Facter::Windows::ProcessorsPhysicalcount do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::ProcessorsPhysicalcount.new }

    let(:value) { '2' }

    before do
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:physicalcount).and_return(value)
    end

    it 'calls Facter::Resolvers::Processors' do
      expect(Facter::Resolvers::Processors).to receive(:resolve).with(:physicalcount)
      fact.call_the_resolver
    end

    it 'returns number of physical processors' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.physicalcount', value: value),
                        an_object_having_attributes(name: 'physicalprocessorcount', value: value, type: :legacy))
    end
  end
end
