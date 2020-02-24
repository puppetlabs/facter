# frozen_string_literal: true

describe Facter::Aix::OsFamily do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Aix::OsFamily.new }

    let(:value) { 'Aix' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      expect(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelname)
      fact.call_the_resolver
    end

    it 'returns os family fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                        an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
    end
  end
end
