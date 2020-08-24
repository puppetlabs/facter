# frozen_string_literal: true

describe Facts::Linux::Networking::Scope6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Scope6.new }

    let(:value) { 'link' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:scope6).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with scope6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:scope6)
    end

    it 'return scope6 fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.scope6', value: value),
                             an_object_having_attributes(name: 'scope6', value: value))
    end

    context 'when scope6 can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Array)
          .and contain_exactly(an_object_having_attributes(name: 'networking.scope6', value: value),
                               an_object_having_attributes(name: 'scope6', value: value))
      end
    end
  end
end
