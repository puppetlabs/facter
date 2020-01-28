# frozen_string_literal: true

describe 'El NetworkingIp' do
  context '#call_the_resolver' do
    let(:value) { '10.16.122.163' }
    subject(:fact) { Facter::El::NetworkingIp.new }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      expect(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:ip).and_return(value)
      fact.call_the_resolver
    end

    it 'returns hostname fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                             an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end
  end
end
