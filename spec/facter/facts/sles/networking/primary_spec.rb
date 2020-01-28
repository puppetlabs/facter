# frozen_string_literal: true

describe 'Sles NetworkingPrimary' do
  context '#call_the_resolver' do
    let(:value) { 'ens160' }
    subject(:fact) { Facter::Sles::NetworkingPrimary.new }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:primary_interface).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      expect(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:primary_interface).and_return(value)
      fact.call_the_resolver
    end

    it 'returns hostname fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.primary', value: value)
    end
  end
end
