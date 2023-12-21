# frozen_string_literal: true

describe Facts::Amzn::Lsbdistcodename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Lsbdistcodename.new }

    let(:value) { 'amzn' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:codename).and_return(value)
    end

    it 'returns lsbdistcodename fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistcodename', value: value, type: :legacy)
    end
  end
end
