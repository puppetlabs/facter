# frozen_string_literal: true

describe Facts::Aix::Kernelversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Kernelversion.new }

    let(:resolver_value) { '6100-09-00-0000' }
    let(:fact_value) { '6100' }

    before do
      allow(Facter::Resolvers::Aix::OsLevel).to receive(:resolve).with(:build).and_return(resolver_value)
    end

    it 'calls Facter::Resolvers::OsLevel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::OsLevel).to have_received(:resolve).with(:build)
    end

    it 'returns kernelversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: fact_value)
    end
  end
end
