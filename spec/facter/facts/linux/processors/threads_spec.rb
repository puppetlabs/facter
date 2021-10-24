# frozen_string_literal: true

describe Facts::Linux::Processors::Threads do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Processors::Threads.new }

    let(:threads_per_core) { 2 }

    before do
      allow(Facter::Resolvers::Linux::Lscpu).to \
        receive(:resolve).with(:threads_per_core).and_return(threads_per_core)
    end

    it 'calls Facter::Resolvers::Linux::Lscpu' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Lscpu).to have_received(:resolve).with(:threads_per_core)
    end

    it 'returns processors core fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.threads', value: threads_per_core)
    end
  end
end
