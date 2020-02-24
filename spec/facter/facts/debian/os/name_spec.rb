# frozen_string_literal: true

describe Facter::Debian::OsName do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Debian::OsName.new }

    let(:value) { 'Debian' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      expect(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id)
      fact.call_the_resolver
    end

    it 'returns operating system name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.name', value: value),
                        an_object_having_attributes(name: 'operatingsystem', value: value, type: :legacy))
    end
  end
end
