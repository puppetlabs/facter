# frozen_string_literal: true

describe Facts::Macosx::Processors::Speed do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Processors::Speed.new }

    let(:speed) { 1_800_000_000 }

    before do
      allow(Facter::Resolvers::Macosx::Processors).to \
        receive(:resolve).with(:speed).and_return(speed)
    end

    it 'calls Facter::Resolvers::Macosx::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Processors).to have_received(:resolve).with(:speed)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.speed', value: speed)
    end
  end
end
