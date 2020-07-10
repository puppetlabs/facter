# frozen_string_literal: true

describe Facts::Aix::Os::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Os::Name.new }

    let(:value) { 'AIX' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      expect(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname)
      fact.call_the_resolver
    end

    it 'returns operating system name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.name', value: value),
                        an_object_having_attributes(name: 'operatingsystem', value: value, type: :legacy))
    end
  end
end
