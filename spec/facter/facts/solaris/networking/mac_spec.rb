# frozen_string_literal: true

describe Facts::Solaris::Networking::Mac do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Networking::Mac.new }

    let(:value) { '64:5a:ed:ea:c3:25' }

    before do
      allow(Facter::Resolvers::Solaris::Networking).to receive(:resolve).with(:mac).and_return(value)
    end

    it 'return macaddress fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                        an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
    end

    context 'when mac can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                          an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
      end
    end
  end
end
