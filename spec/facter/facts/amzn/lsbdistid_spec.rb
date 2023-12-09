# frozen_string_literal: true

describe Facts::Amzn::Lsbdistid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Lsbdistid.new }

    let(:value) { 'amzn' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return(value)
    end

    it 'returns lsbdistid fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistid', value: value, type: :legacy)
    end
  end
end
