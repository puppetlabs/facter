# frozen_string_literal: true

describe Facts::Sles::Kernelrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Kernelrelease.new }

    let(:value) { '3.12.49-11-default' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns kernelrelease fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelrelease', value: value)
    end
  end
end
