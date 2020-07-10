# frozen_string_literal: true

describe Facts::Aix::Networking::Mac do
  subject(:fact) { Facts::Aix::Networking::Mac.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:mac).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { '64:5a:ed:ea:c3:25' }

    it 'calls Facter::Resolvers::Aix::Networking with mac' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:mac)
    end

    it 'returns macaddress fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                        an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: nil),
                        an_object_having_attributes(name: 'macaddress', value: nil, type: :legacy))
    end
  end
end
