# frozen_string_literal: true

describe Facts::Amzn::Lsbdistdescription do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Lsbdistdescription.new }

    let(:value) { 'amzn' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:description).and_return(value)
    end

    it 'returns lsbdistdescription fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistdescription', value: value, type: :legacy)
    end
  end
end
