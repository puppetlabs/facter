# frozen_string_literal: true

describe Facts::Windows::Kernelversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Kernelversion.new }

    let(:kernel_version) { '2016' }

    before do
      allow(Facter::Resolvers::Kernel).to \
        receive(:resolve).with(:kernelversion).and_return(kernel_version)
    end

    it 'calls Facter::Resolvers::Kernel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Kernel).to have_received(:resolve).with(:kernelversion)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: kernel_version)
    end
  end
end
