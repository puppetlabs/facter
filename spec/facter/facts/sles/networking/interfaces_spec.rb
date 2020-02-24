# frozen_string_literal: true

describe Facter::Sles::NetworkingInterfaces do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Sles::NetworkingInterfaces.new }

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

    it 'calls Facter::Resolvers::Hostname' do
      expect(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(value)
      fact.call_the_resolver
    end

    it 'returns hostname fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.interfaces', value: value)
    end
  end
end
