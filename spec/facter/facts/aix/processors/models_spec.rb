# frozen_string_literal: true

describe Facts::Aix::Processors::Models do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Processors::Models.new }

    let(:models) { %w[PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8] }

    before do
      allow(Facter::Resolvers::Aix::Processors).to \
        receive(:resolve).with(:models).and_return(models)
    end

    it 'calls Facter::Resolvers::Aix::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Processors).to have_received(:resolve).with(:models)
    end

    it 'returns processors models fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.models', value: models)
    end
  end
end
