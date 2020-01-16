# frozen_string_literal: true

describe 'Fedora MemorySystemAvailableBytes' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.available_bytes', value: 'value')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:memfree).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.available_bytes', 'value')
                                                  .and_return(expected_fact)

      fact = Facter::El::MemorySystemAvailableBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
