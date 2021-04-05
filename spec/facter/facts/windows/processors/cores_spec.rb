# frozen_string_literal: true

describe Facts::Windows::Processors::Cores do
    describe '#call_the_resolver' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'processors.cores', value: 'value')
        allow(Facter::Resolvers::Processors).to receive(:resolve).with(:cores_per_socket).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('processors.cores', 'value').and_return(expected_fact)
  
        fact = Facts::Windows::Processors::Cores.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end
  end
  