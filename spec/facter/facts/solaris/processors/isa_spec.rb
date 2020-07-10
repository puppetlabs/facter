# frozen_string_literal: true

describe Facts::Solaris::Processors::Isa do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Processors::Isa.new }

    let(:isa) { 'i386' }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return(isa)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:processor)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'processors.isa', value: isa),
                        an_object_having_attributes(name: 'hardwareisa', value: isa, type: :legacy))
    end
  end
end
