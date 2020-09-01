# frozen_string_literal: true

describe Facts::Windows::Networking::Scope6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Scope6.new }

    let(:value) { 'link' }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:scope6).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Windows::Networking).to have_received(:resolve).with(:scope6)
    end

    it 'returns scope for ipv6 address' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.scope6', value: value),
                             an_object_having_attributes(name: 'scope6', value: value))
    end
  end
end
