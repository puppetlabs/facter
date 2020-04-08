# frozen_string_literal: true

describe Facts::Sles::Kernelversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Kernelversion.new }

    let(:resolver_value) { '3.12.49-11-default' }
    let(:fact_value) { '3.12.49' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns kernelversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: fact_value)
    end
  end
end
