# frozen_string_literal: true

describe Facts::Linuxmint::Os::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linuxmint::Os::Name.new }

    let(:value) { 'linuxmint' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id).and_return(value)
    end

    it 'returns operating system name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.name', value: value.capitalize),
                        an_object_having_attributes(name: 'operatingsystem', value: value.capitalize, type: :legacy))
    end
  end
end
