# frozen_string_literal: true

describe Facts::Macosx::Kernelmajversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Kernelmajversion.new }

    let(:resolver_result) { '18.7.0' }
    let(:fact_value) { '18.7' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(resolver_result)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns a kernelmajversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelmajversion', value: fact_value)
    end
  end
end
