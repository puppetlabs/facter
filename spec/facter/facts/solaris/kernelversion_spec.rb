# frozen_string_literal: true

describe Facts::Solaris::Kernelversion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Kernelversion.new }

    let(:value) { '11.4.0.15.0' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelversion).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelversion)
    end

    it 'returns kernelversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: value)
    end
  end
end
