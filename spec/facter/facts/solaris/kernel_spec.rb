# frozen_string_literal: true

describe Facts::Solaris::Kernel do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Kernel.new }

    let(:value) { 'SunOs' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelname)
    end

    it 'returns kernel fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernel', value: value)
    end
  end
end
