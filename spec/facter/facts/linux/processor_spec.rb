# frozen_string_literal: true

describe Facts::Linux::Processor do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Processor.new }

    let(:processor) { ['Intel(R) Xeon(R) Gold 6138 CPU @ 2.00GHz', 'Intel(R) Xeon(R) Gold 6138 CPU @ 2.00GHz'] }

    before do
      allow(Facter::Resolvers::Linux::Processors).to receive(:resolve).with(:models).and_return(processor)
    end

    it 'calls Facter::Resolvers::Linux::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Processors).to have_received(:resolve).with(:models)
    end

    it 'returns legacy facts about each processor' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processor0', value: processor[0], type: :legacy),
                        an_object_having_attributes(name: 'processor1', value: processor[1], type: :legacy))
    end
  end
end
