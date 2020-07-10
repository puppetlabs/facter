# frozen_string_literal: true

describe Facts::Aix::Os::Family do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Os::Family.new }

    let(:value) { 'Aix' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelname)
    end

    it 'returns os family fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                        an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
    end
  end
end
