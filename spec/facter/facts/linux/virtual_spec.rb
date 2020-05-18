# frozen_string_literal: true

describe Facts::Linux::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Virtual.new }

    let(:vm) { 'docker' }

    before do
      allow(Facter::Resolvers::DockerLxc).to \
        receive(:resolve).with(:vm).and_return(vm)
    end

    it 'calls Facter::Resolvers::DockerLxc' do
      fact.call_the_resolver
      expect(Facter::Resolvers::DockerLxc).to have_received(:resolve).with(:vm)
    end

    it 'returns virtual fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'virtual', value: vm)
    end

    context 'when resolver returns nil' do
      let(:vm) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end
  end
end
