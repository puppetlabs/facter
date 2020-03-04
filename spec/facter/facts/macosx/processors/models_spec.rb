# frozen_string_literal: true

describe Facts::Macosx::Processors::Models do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Processors::Models.new }

    let(:models) { ['Intel(R) Core(TM) i7-4980HQ CPU @ 2.80GHz', 'Intel(R) Core(TM) i7-4980HQ CPU @ 2.80GHz'] }

    before do
      allow(Facter::Resolvers::Macosx::Processors).to \
        receive(:resolve).with(:models).and_return(models)
    end

    it 'calls Facter::Resolvers::Macosx::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Processors).to have_received(:resolve).with(:models)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.models', value: models)
    end
  end
end
