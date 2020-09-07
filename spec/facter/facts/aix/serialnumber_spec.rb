# frozen_string_literal: true

describe Facts::Aix::Serialnumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Serialnumber.new }

    let(:value) { '21684EW' }

    before do
      allow(Facter::Resolvers::Aix::Serialnumber).to receive(:resolve).with(:serialnumber).and_return(value)
    end

    it 'calls Facter::Resolvers::Aix::Serialnumber' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Serialnumber).to have_received(:resolve).with(:serialnumber)
    end

    it 'returns serialnumber fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'serialnumber', value: value, type: :legacy)
    end
  end
end
