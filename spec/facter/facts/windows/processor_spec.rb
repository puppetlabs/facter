# frozen_string_literal: true

describe Facts::Windows::Processor do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Processor.new }

    let(:processor) { ['Intel(R) Xeon(R) Gold 6138 CPU @ 2.00GHz', 'Intel(R) Xeon(R) Gold 6138 CPU @ 2.00GHz'] }

    before do
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:models).and_return(processor)
    end

    it 'calls Facter::Resolvers::Processors' do
      expect(Facter::Resolvers::Processors).to receive(:resolve).with(:models)
      fact.call_the_resolver
    end

    it 'returns legacy facts about each processor' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processor0', value: processor[0], type: :legacy),
                        an_object_having_attributes(name: 'processor1', value: processor[1], type: :legacy))
    end
  end
end
