# frozen_string_literal: true

describe Facts::Linux::Processors::Speed do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Processors::Speed.new }

    let(:speed) { 1_800_000_000 }
    let(:converted_speed) { '1.80 GHz' }

    before do
      allow(Facter::Resolvers::Linux::Processors).to \
        receive(:resolve).with(:speed).and_return(speed)
    end

    it 'calls Facter::Resolvers::Linux::Processors' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Processors).to have_received(:resolve).with(:speed)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.speed', value: converted_speed)
    end
  end
end
