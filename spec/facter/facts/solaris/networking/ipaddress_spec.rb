# frozen_string_literal: true

describe 'Solaris NetworkingIpaddress' do
  context '#call_the_resolver' do
    let(:value) { '10.0.0.1' }
    subject(:fact) { Facter::Solaris::NetworkingIpaddress.new }

    before do
      allow(Facter::Resolvers::Solaris::Ipaddress).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::Ipaddress' do
      expect(Facter::Resolvers::Solaris::Ipaddress).to receive(:resolve).with(:ip).and_return(value)
      fact.call_the_resolver
    end

    it 'return ip fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.ip', value: value)
    end
  end
end
