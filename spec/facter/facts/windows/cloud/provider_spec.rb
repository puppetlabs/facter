# frozen_string_literal: true

describe Facts::Windows::Cloud::Provider do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Cloud::Provider.new }

    context 'when on hyperv' do
      before do
        allow(Facter::Resolvers::Az).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('hyperv')
      end

      context 'when az_metadata exists' do
        let(:value) { { 'some' => 'fact' } }

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

    context 'when on a physical machine' do
      before do
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return(nil)
      end

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'cloud.provider', value: nil)
      end
    end
  end
end
