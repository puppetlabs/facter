# frozen_string_literal: true

describe 'Windows ProcessorsCount' do
  context '#call_the_resolver' do
    let(:value) { '2' }
    subject(:fact) { Facter::Windows::ProcessorsCount.new }

    before do
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:count).and_return(value)
    end

    it 'calls Facter::Resolvers::Processors' do
      expect(Facter::Resolvers::Processors).to receive(:resolve).with(:count)
      fact.call_the_resolver
    end

    it 'returns number of processors' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.count', value: value),
                        an_object_having_attributes(name: 'processorcount', value: value, type: :legacy))
    end
  end
end
