# frozen_string_literal: true

describe Facts::Aix::Kernelrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Kernelrelease.new }

    let(:value) { '6100-09-00-0000' }

    before do
      allow(Facter::Resolvers::OsLevel).to receive(:resolve).with(:build).and_return(value)
    end

    it 'calls Facter::Resolvers::OsLevel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::OsLevel).to have_received(:resolve).with(:build)
    end

    it 'returns kernelrelease fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelrelease', value: value)
    end
  end
end
