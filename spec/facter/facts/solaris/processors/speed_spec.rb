# frozen_string_literal: true

describe Facts::Solaris::Processors::Speed do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Processors::Speed.new }

    let(:speed) { 1_800_000_000 }
    let(:converted_speed) { '1.80 GHz' }

    before do
      allow(Facter::Resolvers::Solaris::Processors).to \
        receive(:resolve).with(:speed).and_return(speed)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.speed', value: converted_speed)
    end
  end
end
