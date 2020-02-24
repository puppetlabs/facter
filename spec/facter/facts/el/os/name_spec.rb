# frozen_string_literal: true

describe Facter::El::OsName do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::El::OsName.new }

    let(:value) { 'RedHat' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name).and_return(value)
    end

    it 'calls Facter::Resolvers::OsRelease' do
      expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name)
      fact.call_the_resolver
    end

    it 'returns operating system name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.name', value: value),
                        an_object_having_attributes(name: 'operatingsystem', value: value, type: :legacy))
    end
  end
end
