# frozen_string_literal: true

describe Facts::Macosx::Kernelversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Kernelversion.new }

    let(:value) { '18.7.0' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns kernelversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: value)
    end
  end
end
