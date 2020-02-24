# frozen_string_literal: true

describe Facter::Windows::OsFamily do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::OsFamily.new }

    let(:value) { 'windows' }

    before do
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernel).and_return(value)
    end

    it 'calls Facter::Resolvers::Kernel' do
      expect(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernel)
      fact.call_the_resolver
    end

    it 'returns os family fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                        an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
    end
  end
end
