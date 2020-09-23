# frozen_string_literal: true

describe Facts::Aix::Kernelmajversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Kernelmajversion.new }

    let(:fact_value) { '6100' }
    let(:resolver_value) { '6100-09-00-0000' }

    before do
      allow(Facter::Resolvers::Aix::OsLevel).to receive(:resolve).with(:build).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::OsLevel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::OsLevel).to have_received(:resolve).with(:build)
    end

    it 'returns kernelmajversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelmajversion', value: fact_value)
    end
  end
end
