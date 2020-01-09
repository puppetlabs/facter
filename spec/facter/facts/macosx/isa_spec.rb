# frozen_string_literal: true

describe 'Macosx ProcessorsIsa' do
  context '#call_the_resolver' do
    it 'returns processors fact' do
      value = 'i386'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.isa', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:processor).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.isa', value).and_return(expected_fact)

      fact = Facter::Macosx::ProcessorsIsa.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
