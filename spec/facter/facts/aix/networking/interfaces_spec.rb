# frozen_string_literal: true

describe Facts::Aix::Networking::Interfaces do
  subject(:fact) { Facts::Aix::Networking::Interfaces.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:interfaces).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) do
      {
        'ens160' => {
          'bindings' => [
            {
              'address' => '10.16.116.8',
              'netmask' => '255.255.240.0',
              'network' => '10.16.112.0'
            }
          ]
        }
      }
    end

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns networking.interfaces fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.interfaces', value: value)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { {} }

    it 'returns nil' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.interfaces', value: nil)
    end
  end
end
