# frozen_string_literal: true

describe Facts::Windows::Facterversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Facterversion.new }

    let(:value) { '4.0.3' }

    before do
      allow(Facter::Resolvers::Facterversion).to receive(:resolve).with(:facterversion).and_return(value)
    end

    it 'calls Facter::Resolvers::Facterversion' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Facterversion).to have_received(:resolve).with(:facterversion)
    end

    it 'returns facterversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'facterversion', value: value)
    end
  end
end
