# frozen_string_literal: true

describe Facts::Windows::Cloud::Provider do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Cloud::Provider.new }

    before do
      allow(Facter::Resolvers::Az).to receive(:resolve).with(:metadata).and_return(value)
    end

    context 'when az_metadata exists' do
      let(:value) do
        {
          'some' => 'fact'
        }
      end

      it 'returns azure as cloud.provider' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'cloud.provider', value: 'azure')
      end
    end

    context 'when az_metadata does not exist' do
      let(:value) { {} }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'cloud.provider', value: nil)
      end
    end
  end
end
