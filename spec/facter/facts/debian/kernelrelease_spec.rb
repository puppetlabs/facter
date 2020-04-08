# frozen_string_literal: true

describe Facts::Debian::Kernelrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Kernelrelease.new }

    let(:value) { '6100-09-00-0000' }

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
