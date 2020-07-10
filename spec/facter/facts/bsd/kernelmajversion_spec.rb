# frozen_string_literal: true

describe Facts::Bsd::Kernelmajversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Bsd::Kernelmajversion.new }

    let(:fact_value) { '12' }
    let(:resolver_value) { '12.1-RELEASE-p3' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::OsLevel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns kernelmajversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelmajversion', value: fact_value)
    end
  end
end
