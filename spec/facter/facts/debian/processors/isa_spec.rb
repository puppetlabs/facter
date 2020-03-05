# frozen_string_literal: true

describe Facts::Debian::Processors::Isa do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Processors::Isa.new }

    let(:processors_arch) { 'x86_64' }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return(processors_arch)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:processor)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.isa', value: processors_arch)
    end
  end
end
