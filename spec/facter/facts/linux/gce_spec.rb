# frozen_string_literal: true

describe Facts::Linux::Gce do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Gce.new }

    before do
      allow(Facter::Resolvers::Gce).to receive(:resolve).with(:metadata).and_return(value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(vendor)
    end

    context 'when hypervisor is Gce' do
      let(:vendor) { 'Google' }
      let(:value) do
        {
          'oslogin' => {
            'authenticate' => {
              'sessions' => {
              }
            }
          },
          'project' => {
            'numericProjectId' => 728_618_928_092,
            'projectId' => 'facter-performance-history'
          }
        }
      end

      it 'calls Facter::Resolvers::Linux::Gce' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Gce).to have_received(:resolve).with(:metadata)
      end

      it 'calls Facter::Resolvers::Linux::DmiBios' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:bios_vendor)
      end

      it 'returns gce fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'gce', value: value)
      end
    end

    context 'when hypervisor is not Gce' do
      let(:vendor) { 'unknown' }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'gce', value: nil)
      end
    end
  end
end
