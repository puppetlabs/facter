# frozen_string_literal: true

describe 'Fedora ProcessorsIsa' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'x86_64'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.isa', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.isa', value).and_return(expected_fact)

      fact = Facter::Fedora::ProcessorsIsa.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
