# frozen_string_literal: true

describe Facts::Solaris::Processors::Threads do
    describe '#call_the_resolver' do
      subject(:fact) { Facts::Solaris::Processors::Threads.new }
  
      let(:threads_per_core) { '4' }
  
      before do
        allow(Facter::Resolvers::Solaris::Processors).to \
          receive(:resolve).with(:threads_per_core).and_return(threads_per_core)
      end
  
      it 'calls Facter::Resolvers::Solaris::Processors' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::Processors).to have_received(:resolve).with(:threads_per_core)
      end
  
      it 'returns a resolved fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.threads', value: threads_per_core)
      end
    end
  end
  