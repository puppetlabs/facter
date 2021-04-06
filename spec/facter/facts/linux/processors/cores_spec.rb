# frozen_string_literal: true

describe Facts::Linux::Processors::Cores do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Processors::Cores.new }

    let(:cores_per_socket) { 4 }

    before do
      allow(Facter::Resolvers::Linux::Lscpu).to \
        receive(:resolve).with(:cores_per_socket).and_return(cores_per_socket)
    end

    it 'calls Facter::Resolvers::Linux::Lscpu' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Lscpu).to have_received(:resolve).with(:cores_per_socket)
    end

    it 'returns processors core fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.cores', value: cores_per_socket)
    end
  end
end
