# frozen_string_literal: true

describe Facts::Aix::Kernel do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Kernel.new }

    let(:value) { 'AIX' }

    before do
      allow(Facter::Resolvers::Aix::OsLevel).to receive(:resolve).with(:kernel).and_return(value)
    end

    it 'returns kernel fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernel', value: value)
    end
  end
end
