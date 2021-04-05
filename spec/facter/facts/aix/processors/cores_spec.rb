# frozen_string_literal: true

describe Facts::Aix::Processors::Cores do
    describe '#call_the_resolver' do
      subject(:fact) { Facts::Aix::Processors::Cores.new }
  
      let(:cores_per_socket) { 8 }
  
      before do
        allow(Facter::Resolvers::Aix::Processors).to \
          receive(:resolve).with(:cores_per_socket).and_return(cores_per_socket)
      end
  
      it 'calls Facter::Resolvers::Aix::Processors' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Aix::Processors).to have_received(:resolve).with(:cores_per_socket)
      end
  
      it 'returns processors cores fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'processors.cores', value: cores_per_socket)
      end
    end
  end
  