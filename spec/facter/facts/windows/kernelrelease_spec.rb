# frozen_string_literal: true

describe Facts::Windows::Kernelrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Kernelrelease.new }

    let(:kernel_release) { '2016' }

    before do
      allow(Facter::Resolvers::Kernel).to \
        receive(:resolve).with(:kernelversion).and_return(kernel_release)
    end

    it 'calls Facter::Resolvers::Kernel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Kernel).to have_received(:resolve).with(:kernelversion)
    end

    it 'returns kernelrelease fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelrelease', value: kernel_release)
    end
  end
end
