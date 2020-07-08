# frozen_string_literal: true

describe Facts::Linux::Hypervisors::Docker do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Hypervisors::Docker.new }

    before do
      allow(Facter::Resolvers::Containers).to \
        receive(:resolve).with(:hypervisor).and_return(hv)
    end

    context 'when resolver returns docker' do
      let(:hv) { { docker: { 'id' => 'testid' } } }
      let(:value) { { 'id' => 'testid' } }

      it 'calls Facter::Resolvers::Containers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Containers).to have_received(:resolve).with(:hypervisor)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.docker', value: value)
      end
    end

    context 'when resolver returns lxc' do
      let(:hv) { { lxc: { 'name' => 'test_name' } } }

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.docker', value: nil)
      end
    end

    context 'when resolver returns nil' do
      let(:hv) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.docker', value: hv)
      end
    end

    context 'when docker info is empty' do
      let(:hv) { { docker: {} } }
      let(:value) { {} }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.docker', value: value)
      end
    end
  end
end
