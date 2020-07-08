# frozen_string_literal: true

describe Facts::Linux::Hypervisors::SystemdNspawn do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Hypervisors::SystemdNspawn.new }

    before do
      allow(Facter::Resolvers::Containers).to \
        receive(:resolve).with(:hypervisor).and_return(hv)
    end

    context 'when resolver returns systemd_nspawn' do
      let(:hv) { { systemd_nspawn: { 'id' => 'testid00' } } }
      let(:value) { { 'id' => 'testid00' } }

      it 'calls Facter::Resolvers::Containers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Containers).to have_received(:resolve).with(:hypervisor)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.systemd_nspawn', value: value)
      end
    end

    context 'when resolver returns docker' do
      let(:hv) { { docker: { 'id' => 'testid' } } }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.systemd_nspawn', value: nil)
      end
    end

    context 'when resolver returns nil' do
      let(:hv) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.systemd_nspawn', value: hv)
      end
    end

    context 'when systemd_nspawn info is empty' do
      let(:hv) { { systemd_nspawn: {} } }
      let(:value) { {} }

      it 'returns virtual fact as empty array' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.systemd_nspawn', value: value)
      end
    end
  end
end
