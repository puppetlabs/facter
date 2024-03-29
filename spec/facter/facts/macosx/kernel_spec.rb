# frozen_string_literal: true

describe Facts::Macosx::Kernel do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Kernel.new }

    let(:value) { 'Darwin' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
    end

    it 'returns kernel fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernel', value: value)
    end
  end
end
