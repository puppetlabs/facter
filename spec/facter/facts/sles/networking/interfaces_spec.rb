# frozen_string_literal: true

describe Facts::Sles::Networking::Interfaces do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Networking::Interfaces.new }

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

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:interfaces)
    end

    it 'returns networking.interfaces fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.interfaces', value: value)
    end
  end
end
