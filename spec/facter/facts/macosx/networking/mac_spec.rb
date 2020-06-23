# frozen_string_literal: true

describe Facts::Macosx::Networking::Mac do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Mac.new }

    let(:value) { '64:5a:ed:ea:c3:25' }
    let(:primary_interface) { 'en0' }
    let(:interfaces) { { 'en0' => { mac: value } } }

    before do
      allow(Facter::Resolvers::Macosx::Networking)
        .to receive(:resolve).with(:primary_interface).and_return(primary_interface)
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns macaddress fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                        an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
    end

    context 'when primary interface can not be retrieved' do
      let(:primary_interface) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                          an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
      end
    end

    context 'when interfaces can not be retrieved' do
      let(:interfaces) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                          an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
      end
    end
  end
end
